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
  nat_router_name = var.nat_router_name != "" ? var.nat_router_name : "${var.network_name}-router-${var.primary_region}"
  nat_name        = var.nat_name != "" ? var.nat_name : "${var.network_name}-nat-${var.primary_region}"

  sec_nat_router_name = "${var.network_name}-router-${var.secondary_region}"
  sec_nat_name        = "${var.network_name}-nat-${var.secondary_region}"
}

# ── Hub VPC Network ──────────────────────────────────────────────────────────

resource "google_compute_network" "hub" {
  project                 = var.project_id
  name                    = var.network_name
  description             = var.description
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}

# ── Primary Region: NVA subnet ───────────────────────────────────────────────
# /28 — just enough for NVA LAN interfaces (Palo Alto/Fortinet).
# Not enabled for Private Google Access — NVA controls its own internet path.

resource "google_compute_subnetwork" "nva" {
  project                  = var.project_id
  name                     = "${var.network_name}-nva-${var.primary_region}"
  region                   = var.primary_region
  network                  = google_compute_network.hub.id
  ip_cidr_range            = var.nva_subnet_cidr
  private_ip_google_access = false

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── Primary Region: Services subnet ─────────────────────────────────────────
# Bastion host (IAP), Cloud DNS inbound forwarder, shared internal tools.

resource "google_compute_subnetwork" "services" {
  project                  = var.project_id
  name                     = "${var.network_name}-services-${var.primary_region}"
  region                   = var.primary_region
  network                  = google_compute_network.hub.id
  ip_cidr_range            = var.services_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── Primary Region: PSC subnet ───────────────────────────────────────────────
# Private Service Connect endpoints for googleapis.com, Cloud SQL, etc.

resource "google_compute_subnetwork" "psc" {
  project                  = var.project_id
  name                     = "${var.network_name}-psc-${var.primary_region}"
  region                   = var.primary_region
  network                  = google_compute_network.hub.id
  ip_cidr_range            = var.psc_subnet_cidr
  private_ip_google_access = true
  purpose                  = "PRIVATE"
}

# ── Primary Region: Proxy-only subnet ────────────────────────────────────────
# REQUIRED for Envoy-based L7 Internal HTTPS Load Balancers.
# Must be purpose=REGIONAL_MANAGED_PROXY and role=ACTIVE.

resource "google_compute_subnetwork" "proxy" {
  project       = var.project_id
  name          = "${var.network_name}-proxy-${var.primary_region}"
  region        = var.primary_region
  network       = google_compute_network.hub.id
  ip_cidr_range = var.proxy_subnet_cidr
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# ── Secondary Region (DR): Services subnet ───────────────────────────────────

resource "google_compute_subnetwork" "services_dr" {
  count = var.enable_secondary_region ? 1 : 0

  project                  = var.project_id
  name                     = "${var.network_name}-services-${var.secondary_region}"
  region                   = var.secondary_region
  network                  = google_compute_network.hub.id
  ip_cidr_range            = var.secondary_services_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── Secondary Region (DR): Proxy-only subnet ─────────────────────────────────

resource "google_compute_subnetwork" "proxy_dr" {
  count = var.enable_secondary_region ? 1 : 0

  project       = var.project_id
  name          = "${var.network_name}-proxy-${var.secondary_region}"
  region        = var.secondary_region
  network       = google_compute_network.hub.id
  ip_cidr_range = var.secondary_proxy_subnet_cidr
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# ── Cloud Router (primary) ────────────────────────────────────────────────────

resource "google_compute_router" "hub" {
  count = var.enable_cloud_nat ? 1 : 0

  project = var.project_id
  name    = local.nat_router_name
  region  = var.primary_region
  network = google_compute_network.hub.id

  bgp {
    asn = 64514
  }
}

# ── Cloud NAT (primary) ────────────────────────────────────────────────────

resource "google_compute_router_nat" "hub" {
  count = var.enable_cloud_nat ? 1 : 0

  project                            = var.project_id
  name                               = local.nat_name
  router                             = google_compute_router.hub[0].name
  region                             = var.primary_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  min_ports_per_vm                   = var.nat_min_ports_per_vm

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ── Cloud Router (secondary / DR) ─────────────────────────────────────────────

resource "google_compute_router" "hub_dr" {
  count = (var.enable_cloud_nat && var.enable_secondary_region) ? 1 : 0

  project = var.project_id
  name    = local.sec_nat_router_name
  region  = var.secondary_region
  network = google_compute_network.hub.id

  bgp {
    asn = 64514
  }
}

# ── Cloud NAT (secondary / DR) ────────────────────────────────────────────────

resource "google_compute_router_nat" "hub_dr" {
  count = (var.enable_cloud_nat && var.enable_secondary_region) ? 1 : 0

  project                            = var.project_id
  name                               = local.sec_nat_name
  router                             = google_compute_router.hub_dr[0].name
  region                             = var.secondary_region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  min_ports_per_vm                   = var.nat_min_ports_per_vm

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# ── Firewall: Allow IAP SSH/RDP to hub ───────────────────────────────────────
# IAP source range → bastion and other internal VMs for SSH tunneling.

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

  source_ranges = [
    var.services_subnet_cidr,
    var.nva_subnet_cidr,
  ]
}
