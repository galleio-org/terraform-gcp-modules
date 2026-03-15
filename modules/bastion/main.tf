# ─────────────────────────────────────────────────────────────────────────────
# Bastion Module — Galle.io Platform Model Factory  |  v1.0.0
#
# IAP-enabled bastion host in the Hub VPC services subnet.
# All SSH access goes via Cloud IAP tunnel — no public IP, no open port 22.
#
# Access:
#   gcloud compute ssh bastion --tunnel-through-iap --project=mkdy-net-hub
# ─────────────────────────────────────────────────────────────────────────────

# Dedicated service account for the bastion (least-privilege)
resource "google_service_account" "bastion" {
  project      = var.project_id
  account_id   = "${var.name}-sa"
  display_name = "Bastion Host Service Account"
}

resource "google_project_iam_member" "bastion_roles" {
  for_each = toset(var.service_account_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

# Bastion instance — Shielded VM, no public IP
resource "google_compute_instance" "bastion" {
  project      = var.project_id
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  tags   = var.tags
  labels = var.labels

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnet
    # No access_config block → no external IP (private only)
  }

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  metadata = {
    enable-oslogin = "TRUE"
    block-project-ssh-keys = "TRUE"
  }
}

# Firewall: allow IAP source range → bastion SSH
# This rule already exists in the hub-vpc module; defined here too so bastion
# module can be used standalone (idempotent — Terraform handles duplicate names
# as separate resources per network, so name uniqueness is the caller's concern).
resource "google_compute_firewall" "allow_iap_bastion" {
  project = var.project_id
  name    = "${var.name}-allow-iap"
  network = var.network

  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = concat(["35.235.240.0/20"], var.allowed_source_ranges)
  target_tags   = ["bastion", "iap-ssh"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
