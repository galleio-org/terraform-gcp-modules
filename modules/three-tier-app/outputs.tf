output "web_instance_group" {
  description = "Web tier MIG instance group URL — use as backend for External HTTPS LB"
  value       = google_compute_region_instance_group_manager.web.instance_group
}

output "app_instance_group" {
  description = "App tier MIG instance group URL"
  value       = google_compute_region_instance_group_manager.app.instance_group
}

output "app_ilb_ip" {
  description = "Internal IP of the app tier load balancer"
  value       = google_compute_forwarding_rule.app_ilb.ip_address
}

output "web_service_account_email" {
  value = local.web_sa_email
}

output "app_service_account_email" {
  value = local.app_sa_email
}

output "web_health_check_id" {
  value = google_compute_health_check.web.id
}
