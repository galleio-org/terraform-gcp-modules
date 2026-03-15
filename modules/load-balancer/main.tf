# Galle.io Load Balancer Module
# Creates an HTTP(S) Load Balancer

# Backend Service
resource "google_compute_backend_service" "backend" {
  name        = "${var.name}-backend"
  project     = var.project_id
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30
  enable_cdn  = var.enable_cdn

  backend {
    group           = var.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  health_checks = [var.health_check]

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

# URL Map
resource "google_compute_url_map" "urlmap" {
  name            = "${var.name}-urlmap"
  project         = var.project_id
  default_service = google_compute_backend_service.backend.id
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "proxy" {
  name    = "${var.name}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.urlmap.id
}

# Global Forwarding Rule (External IP)
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name        = "${var.name}-forwarding-rule"
  project     = var.project_id
  target      = google_compute_target_http_proxy.proxy.id
  port_range  = "80"
  ip_protocol = "TCP"
}
