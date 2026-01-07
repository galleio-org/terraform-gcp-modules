# GalleIO VPC Module
# Creates a VPC network with custom mode (no auto subnets)

resource "google_compute_network" "vpc" {
  name                    = var.name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  description             = "VPC created by GalleIO"
}
