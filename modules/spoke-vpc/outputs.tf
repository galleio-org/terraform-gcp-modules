output "network_id" {
  description = "The ID of the spoke VPC network"
  value       = google_compute_network.spoke.id
}

output "vpc_id" {
  description = "Alias for network_id"
  value       = google_compute_network.spoke.id
}

output "network_name" {
  description = "The name of the spoke VPC network"
  value       = google_compute_network.spoke.name
}

output "network_self_link" {
  description = "The self_link of the spoke VPC"
  value       = google_compute_network.spoke.self_link
}

output "vpc_self_link" {
  description = "Alias for network_self_link"
  value       = google_compute_network.spoke.self_link
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



output "gke_subnet_id" {
  description = "GKE node subnet ID. Empty string if GKE subnet not enabled."
  value       = length(google_compute_subnetwork.gke) > 0 ? google_compute_subnetwork.gke[0].id : ""
}

output "gke_subnet_self_link" {
  value = length(google_compute_subnetwork.gke) > 0 ? google_compute_subnetwork.gke[0].self_link : ""
}

output "gke_pods_range_name" {
  description = "Name of the GKE pods secondary range — pass to ip_range_pods in GKE cluster"
  value       = local.gke_pods_range_name
}

output "gke_services_range_name" {
  description = "Name of the GKE services secondary range — pass to ip_range_services in GKE cluster"
  value       = local.gke_services_range_name
}

output "ncc_spoke_id" {
  description = "NCC VPC spoke resource ID. Empty string if NCC not enabled."
  value       = length(google_network_connectivity_spoke.vpc_spoke) > 0 ? google_network_connectivity_spoke.vpc_spoke[0].id : ""
}
