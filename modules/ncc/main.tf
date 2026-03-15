# ─────────────────────────────────────────────────────────────────────────────
# NCC Module — Galle.io Platform Model Factory  |  v1.0.0
#
# Creates the NCC hub and attaches VPC + VPN spokes.
#
# Usage:
#   module "ncc" {
#     source     = "github.com/galleio-org/terraform-gcp-modules//modules/ncc"
#     project_id = "mkdy-net-hub"
#     hub_name   = "mkdy-ncc-hub"
#     vpc_spokes = [
#       {
#         name        = "mkdy-dev-spoke"
#         network_uri = module.dev_spoke.network_self_link
#       },
#       {
#         name        = "mkdy-prod-spoke"
#         network_uri = module.prod_spoke.network_self_link
#       }
#     ]
#   }
# ─────────────────────────────────────────────────────────────────────────────

resource "google_network_connectivity_hub" "hub" {
  project     = var.project_id
  name        = var.hub_name
  description = var.hub_description
  labels      = var.labels
}

resource "google_network_connectivity_spoke" "vpc" {
  for_each = { for s in var.vpc_spokes : s.name => s }

  project  = var.project_id
  name     = each.value.name
  location = each.value.location
  hub      = google_network_connectivity_hub.hub.id
  labels   = var.labels

  linked_vpc_network {
    uri                   = each.value.network_uri
    exclude_export_ranges = each.value.exclude_export_ranges
  }
}

resource "google_network_connectivity_spoke" "vpn" {
  for_each = { for s in var.vpn_spokes : s.name => s }

  project  = var.project_id
  name     = each.value.name
  location = each.value.location
  hub      = google_network_connectivity_hub.hub.id
  labels   = var.labels

  linked_vpn_tunnels {
    dynamic "uris" {
      for_each = each.value.vpn_tunnels
      content {
        uri = uris.value.uri
      }
    }
    site_to_site_data_transfer = each.value.site_to_site_data_transfer
  }
}
