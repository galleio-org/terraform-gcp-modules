# ─────────────────────────────────────────────────────────────────────────────
# Three-Tier App Module — Galle.io Platform Model Factory  |  v1.0.0
#
# Web tier  → External HTTPS LB (MIG backends)
# App tier  → Internal L4 TCP LB (MIG backends, web tier → app tier)
# DB tier   → Not managed here — use terraform-google-modules/sql-db separately
#
# Resources created:
#   Web tier:   Instance template, Regional MIG, Autoscaler, Health check
#   App tier:   Instance template, Regional MIG, Autoscaler, Health check
#   ILB:        Internal TCP L4 forwarding rule + backend service (web→app)
#   Firewalls:  Web egress → app, app egress → db, health check ingress
# ─────────────────────────────────────────────────────────────────────────────

locals {
  web_sa_email = var.web_service_account != "" ? var.web_service_account : google_service_account.web[0].email
  app_sa_email = var.app_service_account != "" ? var.app_service_account : google_service_account.app[0].email
}

# ── Service Accounts ─────────────────────────────────────────────────────────

resource "google_service_account" "web" {
  count        = var.web_service_account == "" ? 1 : 0
  project      = var.project_id
  account_id   = "${var.name_prefix}-web-sa"
  display_name = "${var.name_prefix} Web Tier"
}

resource "google_service_account" "app" {
  count        = var.app_service_account == "" ? 1 : 0
  project      = var.project_id
  account_id   = "${var.name_prefix}-app-sa"
  display_name = "${var.name_prefix} App Tier"
}

# ── Web tier ──────────────────────────────────────────────────────────────────

resource "google_compute_instance_template" "web" {
  project      = var.project_id
  name_prefix  = "${var.name_prefix}-web-"
  machine_type = var.web_machine_type
  region       = var.region
  labels       = merge(var.labels, { tier = "web" })
  tags         = ["allow-health-check", "${var.name_prefix}-web"]

  disk {
    source_image = var.web_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.web_disk_size_gb
    disk_type    = "pd-balanced"
  }

  network_interface {
    network    = var.network
    subnetwork = var.web_subnet
    # No access_config — org policy prohibits external IPs
  }

  service_account {
    email  = local.web_sa_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    startup-script = var.web_startup_script
    enable-oslogin = "TRUE"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "web" {
  project            = var.project_id
  name               = "${var.name_prefix}-web-mig"
  region             = var.region
  base_instance_name = "${var.name_prefix}-web"

  version {
    instance_template = google_compute_instance_template.web.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.web.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "web" {
  project = var.project_id
  name    = "${var.name_prefix}-web-as"
  region  = var.region
  target  = google_compute_region_instance_group_manager.web.id

  autoscaling_policy {
    min_replicas    = var.web_min_replicas
    max_replicas    = var.web_max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_health_check" "web" {
  project = var.project_id
  name    = "${var.name_prefix}-web-hc"

  http_health_check {
    port         = 80
    request_path = var.web_health_check_path
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

# ── App tier ──────────────────────────────────────────────────────────────────

resource "google_compute_instance_template" "app" {
  project      = var.project_id
  name_prefix  = "${var.name_prefix}-app-"
  machine_type = var.app_machine_type
  region       = var.region
  labels       = merge(var.labels, { tier = "app" })
  tags         = ["allow-health-check", "${var.name_prefix}-app"]

  disk {
    source_image = var.app_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.app_disk_size_gb
    disk_type    = "pd-balanced"
  }

  network_interface {
    network    = var.network
    subnetwork = var.app_subnet
  }

  service_account {
    email  = local.app_sa_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    startup-script = var.app_startup_script
    enable-oslogin = "TRUE"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_instance_group_manager" "app" {
  project            = var.project_id
  name               = "${var.name_prefix}-app-mig"
  region             = var.region
  base_instance_name = "${var.name_prefix}-app"

  version {
    instance_template = google_compute_instance_template.app.id
  }

  named_port {
    name = "app"
    port = var.app_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.app.id
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "app" {
  project = var.project_id
  name    = "${var.name_prefix}-app-as"
  region  = var.region
  target  = google_compute_region_instance_group_manager.app.id

  autoscaling_policy {
    min_replicas    = var.app_min_replicas
    max_replicas    = var.app_max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

resource "google_compute_health_check" "app" {
  project = var.project_id
  name    = "${var.name_prefix}-app-hc"

  http_health_check {
    port         = var.app_port
    request_path = var.app_health_check_path
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

# ── Internal L4 LB: web → app tier ────────────────────────────────────────────

resource "google_compute_region_backend_service" "app_ilb" {
  project               = var.project_id
  name                  = "${var.name_prefix}-app-ilb-bs"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_health_check.app.id]

  backend {
    group          = google_compute_region_instance_group_manager.app.instance_group
    balancing_mode = "CONNECTION"
  }
}

resource "google_compute_forwarding_rule" "app_ilb" {
  project               = var.project_id
  name                  = "${var.name_prefix}-app-ilb"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.app_ilb.id
  all_ports             = true
  network               = var.network
  subnetwork            = var.app_subnet
}

# ── Firewalls ─────────────────────────────────────────────────────────────────

# Allow web tier → app tier
resource "google_compute_firewall" "web_to_app" {
  project = var.project_id
  name    = "${var.name_prefix}-web-to-app"
  network = var.network

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = [tostring(var.app_port)]
  }

  source_tags = ["${var.name_prefix}-web"]
  target_tags = ["${var.name_prefix}-app"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow app tier → Cloud SQL (port 5432 PostgreSQL, 3306 MySQL)
resource "google_compute_firewall" "app_to_db" {
  project = var.project_id
  name    = "${var.name_prefix}-app-to-db"
  network = var.network

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["5432", "3306"]
  }

  source_tags = ["${var.name_prefix}-app"]
  target_tags = ["${var.name_prefix}-db"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
