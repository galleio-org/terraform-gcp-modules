output "instance_group" {
  description = "The URL of the instance group"
  value       = google_compute_region_instance_group_manager.mig.instance_group
}

output "instance_template" {
  description = "The self_link of the instance template"
  value       = google_compute_instance_template.template.self_link
}

output "mig_name" {
  description = "The name of the MIG"
  value       = google_compute_region_instance_group_manager.mig.name
}

output "health_check_self_link" {
  description = "The self_link of the health check"
  value       = google_compute_health_check.mig.self_link
}
