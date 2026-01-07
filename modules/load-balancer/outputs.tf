output "lb_ip_address" {
  description = "The external IP address of the load balancer"
  value       = google_compute_global_forwarding_rule.forwarding_rule.ip_address
}

output "lb_url" {
  description = "The URL to access the load balancer"
  value       = "http://${google_compute_global_forwarding_rule.forwarding_rule.ip_address}"
}

output "backend_service_name" {
  description = "The name of the backend service"
  value       = google_compute_backend_service.backend.name
}
