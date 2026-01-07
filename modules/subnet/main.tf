# GalleIO Subnet Module
# Creates a subnet within a VPC

resource "google_compute_subnetwork" "subnet" {
  name                     = var.name
  project                  = var.project_id
  region                   = var.region
  network                  = var.network_self_link
  ip_cidr_range            = var.cidr
  private_ip_google_access = var.private_google_access
  description              = "Subnet created by GalleIO"

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []
    content {
      aggregation_interval = "INTERVAL_10_MIN"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }
}
