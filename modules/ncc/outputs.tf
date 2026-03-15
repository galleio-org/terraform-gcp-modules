output "hub_id" {
  description = "NCC hub resource ID — pass to spoke-vpc module as ncc_hub_id"
  value       = google_network_connectivity_hub.hub.id
}

output "hub_name" {
  value = google_network_connectivity_hub.hub.name
}

output "vpc_spoke_ids" {
  description = "Map of spoke name → spoke resource ID"
  value       = { for k, v in google_network_connectivity_spoke.vpc : k => v.id }
}

output "vpn_spoke_ids" {
  description = "Map of VPN spoke name → spoke resource ID"
  value       = { for k, v in google_network_connectivity_spoke.vpn : k => v.id }
}
