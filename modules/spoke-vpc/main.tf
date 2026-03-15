# ─────────────────────────────────────────────────────────────────────────────
# Spoke VPC Module — Galle.io Platform Model Factory  |  v1.0.0
#
# Creates a workload spoke VPC for hub-and-spoke topology:
#   - Spoke VPC (GLOBAL routing, no auto-subnets)
#   - Web tier subnet       — MIG/GKE external LB backends
#   - App tier subnet       — Internal LB backends, APIs
#   - DB tier subnet        — Cloud SQL private IP, AlloyDB
#   - Proxy-only subnet     — Envoy L7 Internal LBs (required, /23 minimum)
#   - GKE subnet            — Pre-allocated node pool + secondary ranges
#   - NCC VPC spoke         — Attaches this VPC to the NCC hub
#
# Usage:
#   module "dev_spoke" {
#     source          = "github.com/galleio-org/terraform-gcp-modules//modules/spoke-vpc"
#     project_id      = "mkdy-app-dev"
#     network_name    = "mkdy-dev-spoke-vpc"
#     region          = "us-east4"
#     environment     = "dev"
#     web_subnet_cidr    = "10.0.30.0/24"
#     app_subnet_cidr    = "10.0.31.0/24"
#     db_subnet_cidr     = "10.0.32.0/24"
#     proxy_subnet_cidr  = "10.10.250.0/23"
#     gke_subnet_cidr    = "10.0.48.0/22"
#     ncc_hub_id         = module.ncc.hub_id
#     ncc_hub_project    = "mkdy-net-hub"
#   }
# ─────────────────────────────────────────────────────────────────────────────

locals {
  gke_pods_range_name     = var.gke_pods_range_name != "" ? var.gke_pods_range_name : "gke-pods-${var.environment}"
  gke_services_range_name = var.gke_services_range_name != "" ? var.gke_services_range_name : "gke-services-${var.environment}"
  ncc_spoke_name          = var.ncc_spoke_name != "" ? var.ncc_spoke_name : "${var.network_name}-spoke"
}

# ── Spoke VPC Network ────────────────────────────────────────────────────────

resource "google_compute_network" "spoke" {
  project                 = var.project_id
  name                    = var.network_name
  description             = var.description
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}

# ── Web tier subnet ──────────────────────────────────────────────────────────
# External LB backends land here. MIG instance groups for web tier.
# GKE node pools can also use this subnet if web workloads run on GKE.

resource "google_compute_subnetwork" "web" {
  project                  = var.project_id
  name                     = "${var.environment}-web-${var.region}"
  region                   = var.region
  network                  = google_compute_network.spoke.id
  ip_cidr_range            = var.web_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── App tier subnet ───────────────────────────────────────────────────────────
# Internal LB backends. Services, APIs, business logic tier.

resource "google_compute_subnetwork" "app" {
  project                  = var.project_id
  name                     = "${var.environment}-app-${var.region}"
  region                   = var.region
  network                  = google_compute_network.spoke.id
  ip_cidr_range            = var.app_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── DB tier subnet ────────────────────────────────────────────────────────────
# Cloud SQL private IP, AlloyDB. No external IPs ever.

resource "google_compute_subnetwork" "db" {
  project                  = var.project_id
  name                     = "${var.environment}-db-${var.region}"
  region                   = var.region
  network                  = google_compute_network.spoke.id
  ip_cidr_range            = var.db_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── Proxy-only subnet ─────────────────────────────────────────────────────────
# REQUIRED for Envoy-based L7 Internal HTTPS LBs in this spoke.
# /23 minimum — each Envoy backend consumes one IP per proxy VM.

resource "google_compute_subnetwork" "proxy" {
  project       = var.project_id
  name          = "${var.environment}-proxy-${var.region}"
  region        = var.region
  network       = google_compute_network.spoke.id
  ip_cidr_range = var.proxy_subnet_cidr
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# ── GKE node subnet with secondary ranges ────────────────────────────────────
# Pre-allocated even before GKE is deployed — secondary ranges cannot be
# added to existing subnets without re-IPing the entire subnet.

resource "google_compute_subnetwork" "gke" {
  count = (var.enable_gke_subnet && var.gke_subnet_cidr != "") ? 1 : 0

  project                  = var.project_id
  name                     = "${var.environment}-gke-${var.region}"
  region                   = var.region
  network                  = google_compute_network.spoke.id
  ip_cidr_range            = var.gke_subnet_cidr
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = local.gke_pods_range_name
    ip_cidr_range = var.gke_pods_cidr
  }

  secondary_ip_range {
    range_name    = local.gke_services_range_name
    ip_cidr_range = var.gke_services_cidr
  }

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ── NCC VPC Spoke Attachment ─────────────────────────────────────────────────
# Attaches this spoke VPC to the NCC hub so it can communicate with:
#   - Other spoke VPCs (via NCC transitive routing)
#   - Hub VPC shared services (NAT, DNS, bastion)
#   - On-prem network (via hub VPN/Interconnect spoke)

resource "google_network_connectivity_spoke" "vpc_spoke" {
  count = (var.attach_to_ncc && var.ncc_hub_id != "") ? 1 : 0

  project  = var.ncc_hub_project != "" ? var.ncc_hub_project : var.project_id
  name     = local.ncc_spoke_name
  location = "global"
  hub      = var.ncc_hub_id

  linked_vpc_network {
    uri                  = google_compute_network.spoke.self_link
    exclude_export_ranges = []
  }

  labels = var.labels
}

# ── Firewall: Allow health checks ────────────────────────────────────────────
# GCP health check probers must reach MIG instances.

resource "google_compute_firewall" "allow_health_checks" {
  project = var.project_id
  name    = "${var.network_name}-allow-hc"
  network = google_compute_network.spoke.id

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
  }

  # GCP health check source ranges (L4 and L7)
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22", "209.85.152.0/22", "209.85.204.0/22"]
  target_tags   = ["allow-health-check"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# ── Firewall: Allow spoke-internal traffic ────────────────────────────────────

resource "google_compute_firewall" "allow_internal" {
  project = var.project_id
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.spoke.id

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
    var.web_subnet_cidr,
    var.app_subnet_cidr,
    var.db_subnet_cidr,
  ]
}
