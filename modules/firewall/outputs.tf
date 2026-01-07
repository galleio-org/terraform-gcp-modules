output "ssh_firewall_name" {
  description = "The name of the SSH firewall rule"
  value       = var.enable_ssh ? google_compute_firewall.ssh[0].name : null
}

output "http_firewall_name" {
  description = "The name of the HTTP firewall rule"
  value       = var.enable_http ? google_compute_firewall.http[0].name : null
}

output "https_firewall_name" {
  description = "The name of the HTTPS firewall rule"
  value       = var.enable_https ? google_compute_firewall.https[0].name : null
}

output "internal_firewall_name" {
  description = "The name of the internal firewall rule"
  value       = var.enable_internal ? google_compute_firewall.internal[0].name : null
}

output "health_check_firewall_name" {
  description = "The name of the health check firewall rule"
  value       = var.enable_health_check ? google_compute_firewall.health_check[0].name : null
}
