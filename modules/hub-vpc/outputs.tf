output "network_id" {
  description = "The ID of the hub VPC network"
  value       = google_compute_network.hub.id
}

output "vpc_id" {
  description = "Alias for network_id"
  value       = google_compute_network.hub.id
}

output "network_name" {
  description = "The name of the hub VPC network"
  value       = google_compute_network.hub.name
}

output "network_self_link" {
  description = "The self_link of the hub VPC"
  value       = google_compute_network.hub.self_link
}

output "vpc_self_link" {
  description = "Alias for network_self_link"
  value       = google_compute_network.hub.self_link
}

output "subnets" {
  description = "Map of all dynamically generated subnets"
  value       = google_compute_subnetwork.subnets
}

output "subnets_ids" {
  description = "Map of subnet names to their IDs"
  value       = { for k, s in google_compute_subnetwork.subnets : k => s.id }
}

output "subnets_self_links" {
  description = "Map of subnet names to their self_links"
  value       = { for k, s in google_compute_subnetwork.subnets : k => s.self_link }
}

output "router_name" {
  description = "Name of the first Cloud Router created (if nat enabled)"
  value       = var.enable_cloud_nat && length(google_compute_router.hub) > 0 ? values(google_compute_router.hub)[0].name : ""
}

output "nat_router_name" {
  description = "Alias for router_name"
  value       = var.enable_cloud_nat && length(google_compute_router.hub) > 0 ? values(google_compute_router.hub)[0].name : ""
}

output "routers" {
  description = "Map of all created Cloud Routers by region"
  value       = google_compute_router.hub
}
