output "network_id" {
  description = "The ID of the hub VPC network"
  value       = google_compute_network.hub.id
}

output "network_name" {
  description = "The name of the hub VPC network"
  value       = google_compute_network.hub.name
}

output "network_self_link" {
  description = "The self_link of the hub VPC — used for NCC spoke attachment and Shared VPC"
  value       = google_compute_network.hub.self_link
}

output "services_subnet_id" {
  description = "ID of the hub services subnet (Bastion, DNS forwarder)"
  value       = google_compute_subnetwork.services.id
}

output "services_subnet_self_link" {
  description = "Self link of the hub services subnet"
  value       = google_compute_subnetwork.services.self_link
}

output "psc_subnet_id" {
  description = "ID of the PSC subnet"
  value       = google_compute_subnetwork.psc.id
}

output "proxy_subnet_id" {
  description = "ID of the proxy-only subnet (required for ILB reference)"
  value       = google_compute_subnetwork.proxy.id
}

output "nat_router_name" {
  description = "Name of the Cloud Router (primary region)"
  value       = var.enable_cloud_nat ? google_compute_router.hub[0].name : ""
}

output "nat_name" {
  description = "Name of the Cloud NAT resource (primary region)"
  value       = var.enable_cloud_nat ? google_compute_router_nat.hub[0].name : ""
}
