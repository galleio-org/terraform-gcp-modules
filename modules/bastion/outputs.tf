output "instance_name" {
  value = google_compute_instance.bastion.name
}

output "instance_id" {
  value = google_compute_instance.bastion.instance_id
}

output "internal_ip" {
  description = "Private IP of the bastion host"
  value       = google_compute_instance.bastion.network_interface[0].network_ip
}

output "service_account_email" {
  value = google_service_account.bastion.email
}

output "ssh_command" {
  description = "gcloud command to SSH via IAP tunnel"
  value       = "gcloud compute ssh ${google_compute_instance.bastion.name} --tunnel-through-iap --project=${var.project_id} --zone=${var.zone}"
}
