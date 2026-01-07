# GalleIO MIG Module
# Creates a Managed Instance Group with autoscaling

# Instance Template
resource "google_compute_instance_template" "template" {
  name_prefix  = "${var.name}-"
  project      = var.project_id
  machine_type = var.machine_type
  region       = var.region
  tags         = var.network_tags

  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-standard"
  }

  network_interface {
    subnetwork = var.subnet_self_link
    # No access_config = no external IP (recommended for security)
  }

  metadata = {
    startup-script = var.startup_script
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  labels = {
    managed_by = "galleio"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Regional Managed Instance Group
resource "google_compute_region_instance_group_manager" "mig" {
  name               = var.name
  project            = var.project_id
  region             = var.region
  base_instance_name = var.name
  target_size        = var.min_replicas

  version {
    instance_template = google_compute_instance_template.template.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.mig.id
    initial_delay_sec = 300
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 3
    max_unavailable_fixed = 0
  }
}

# Health Check for Auto-healing
resource "google_compute_health_check" "mig" {
  name    = "${var.name}-health-check"
  project = var.project_id

  http_health_check {
    port         = 80
    request_path = var.health_check_path
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

# Autoscaler
resource "google_compute_region_autoscaler" "autoscaler" {
  name    = "${var.name}-autoscaler"
  project = var.project_id
  region  = var.region
  target  = google_compute_region_instance_group_manager.mig.id

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = var.cooldown_period

    cpu_utilization {
      target = var.target_cpu
    }
  }
}
