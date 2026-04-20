# ─────────────────────────────────────────────────────────────────────────────
# Hub VPC Module — Galle.io Platform Model Factory  |  v1.0.0
#
# Creates the centralized Hub VPC in a hub-and-spoke topology:
#   - Hub VPC network (GLOBAL routing, no auto-subnets)
#   - NVA subnet          — /28  — Palo Alto/Fortinet LAN interfaces
#   - Services subnet     — /24  — Bastion, DNS forwarder, internal tooling
#   - PSC subnet          — /24  — Private Service Connect endpoints
#   - Proxy-only subnet   — /23+ — Envoy L7 Internal LB backends
#   - (optional) Secondary-region mirrors for DR
#   - Cloud Router + Cloud NAT (optional, enabled by default)
#
# Usage:
#   module "hub_vpc" {
#     source       = "github.com/galleio-org/terraform-gcp-modules//modules/hub-vpc"
#     project_id   = "mkdy-net-hub"
#     network_name = "mkdy-hub-vpc"
#     primary_region           = "us-east4"
#     services_subnet_cidr     = "10.0.1.0/24"
#     psc_subnet_cidr          = "10.0.2.0/24"
#     proxy_subnet_cidr        = "10.0.3.0/24"
#     enable_secondary_region  = true
#     secondary_region         = "us-central1"
#   }
# ─────────────────────────────────────────────────────────────────────────────

locals {
  unique_regions = toset([for k, v in var.subnets : v.region])
}

# ── Hub VPC Network ──────────────────────────────────────────────────────────

resource "google_compute_network" "hub" {
  project                 = var.project_id
  name                    = var.network_name
  description             = var.description
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}

# ── Dynamic Subnets ──────────────────────────────────────────────────────────

resource "google_compute_subnetwork" "subnets" {
  for_each = var.subnets

  project                  = var.project_id
  name                     = "${var.network_name}-${each.value.purpose}-${each.value.region}"
  region                   = each.value.region
  network                  = google_compute_network.hub.id
  ip_cidr_range            = each.value.cidr
  private_ip_google_access = each.value.purpose != "nva"

  purpose = each.value.purpose == "proxy" ? "REGIONAL_MANAGED_PROXY" : (each.value.purpose == "psc" ? "PRIVATE" : null)
  role    = each.value.purpose == "proxy" ? "ACTIVE" : null

  dynamic "log_config" {
    for_each = each.value.purpose != "proxy" && each.value.purpose != "psc" ? [1] : []
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}

# ── Dynamic Cloud Router per Region ──────────────────────────────────────────

resource "google_compute_router" "hub" {
  for_each = var.enable_cloud_nat ? local.unique_regions : []

  project = var.project_id
  name    = "${var.network_name}-router-${each.key}"
  region  = each.key
  network = google_compute_network.hub.id

  bgp {
    asn = 64514
  }
}

# ── Dynamic Cloud NAT per Region ─────────────────────────────────────────────

resource "google_compute_router_nat" "hub" {
  for_each = var.enable_cloud_nat ? local.unique_regions : []

  project                            = var.project_id
  name                               = "${var.network_name}-nat-${each.key}"
  router                             = google_compute_router.hub[each.key].name
  region                             = each.key
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  min_ports_per_vm                   = var.nat_min_ports_per_vm

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ── Firewall: Allow IAP SSH/RDP to hub ───────────────────────────────────────

resource "google_compute_firewall" "allow_iap_ssh" {
  project = var.project_id
  name    = "${var.network_name}-allow-iap-ssh"
  network = google_compute_network.hub.id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["35.235.240.0/20"]  # Google IAP range
  target_tags   = ["iap-ssh"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# ── Firewall: Allow internal hub traffic ─────────────────────────────────────

resource "google_compute_firewall" "allow_internal" {
  project = var.project_id
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.hub.id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = length(var.subnets) > 0 ? [for s in var.subnets : s.cidr] : ["10.0.0.0/8"]
}
