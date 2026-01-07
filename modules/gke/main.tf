# GalleIO GKE Module
# Creates a GKE Autopilot cluster

resource "google_container_cluster" "cluster" {
  name     = var.name
  project  = var.project_id
  location = var.region

  # Autopilot mode
  enable_autopilot = true

  network    = var.network_self_link
  subnetwork = var.subnet_self_link

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Master authorized networks
  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    # Let GKE auto-allocate secondary ranges
  }

  # Release channel
  release_channel {
    channel = var.release_channel
  }

  # Deletion protection (set to false for dev environments)
  deletion_protection = var.deletion_protection

  resource_labels = {
    managed_by = "galleio"
  }
}
