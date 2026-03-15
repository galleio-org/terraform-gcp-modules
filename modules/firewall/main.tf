# Galle.io Firewall Module
# Creates common firewall rules for a VPC

# SSH Access (typically from IAP)
resource "google_compute_firewall" "ssh" {
  count = var.enable_ssh ? 1 : 0

  name        = "${var.network_name}-allow-ssh"
  project     = var.project_id
  network     = var.network_self_link
  description = "Allow SSH access - Created by Galle.io"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = length(var.target_tags) > 0 ? var.target_tags : null
}

# HTTP Access
resource "google_compute_firewall" "http" {
  count = var.enable_http ? 1 : 0

  name        = "${var.network_name}-allow-http"
  project     = var.project_id
  network     = var.network_self_link
  description = "Allow HTTP access - Created by Galle.io"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = length(var.target_tags) > 0 ? var.target_tags : null
}

# HTTPS Access
resource "google_compute_firewall" "https" {
  count = var.enable_https ? 1 : 0

  name        = "${var.network_name}-allow-https"
  project     = var.project_id
  network     = var.network_self_link
  description = "Allow HTTPS access - Created by Galle.io"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = length(var.target_tags) > 0 ? var.target_tags : null
}

# Internal Communication
resource "google_compute_firewall" "internal" {
  count = var.enable_internal ? 1 : 0

  name        = "${var.network_name}-allow-internal"
  project     = var.project_id
  network     = var.network_self_link
  description = "Allow internal communication - Created by Galle.io"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = var.internal_ranges
}

# Health Check Access (for Load Balancers)
resource "google_compute_firewall" "health_check" {
  count = var.enable_health_check ? 1 : 0

  name        = "${var.network_name}-allow-health-check"
  project     = var.project_id
  network     = var.network_self_link
  description = "Allow GCP health checks - Created by Galle.io"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  # Google Cloud health check IP ranges
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = length(var.target_tags) > 0 ? var.target_tags : null
}
