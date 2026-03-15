variable "project_id" {
  description = "GCP project ID for the workload (the spoke service project)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for all resource names (e.g. mkdy-dev)"
  type        = string
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
  default     = "us-east4"
}

variable "network" {
  description = "VPC network name or self_link"
  type        = string
}

# ── Web tier ─────────────────────────────────────────────────────────────────

variable "web_subnet" {
  description = "Subnet self_link for web tier MIG instances"
  type        = string
}

variable "web_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "web_image" {
  description = "Boot image for web tier VMs"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-12"
}

variable "web_disk_size_gb" {
  type    = number
  default = 20
}

variable "web_min_replicas" {
  type    = number
  default = 1
}

variable "web_max_replicas" {
  type    = number
  default = 3
}

variable "web_startup_script" {
  description = "Startup script for web tier VMs (installs nginx/apache etc.)"
  type        = string
  default     = ""
}

variable "web_service_account" {
  description = "Service account email for web tier VMs. Leave empty to create one."
  type        = string
  default     = ""
}

# ── App tier ─────────────────────────────────────────────────────────────────

variable "app_subnet" {
  description = "Subnet self_link for app tier MIG instances"
  type        = string
}

variable "app_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "app_image" {
  type    = string
  default = "projects/debian-cloud/global/images/family/debian-12"
}

variable "app_disk_size_gb" {
  type    = number
  default = 20
}

variable "app_min_replicas" {
  type    = number
  default = 1
}

variable "app_max_replicas" {
  type    = number
  default = 3
}

variable "app_startup_script" {
  description = "Startup script for app tier VMs (installs app server etc.)"
  type        = string
  default     = ""
}

variable "app_service_account" {
  description = "Service account email for app tier VMs. Leave empty to create one."
  type        = string
  default     = ""
}

variable "app_port" {
  description = "TCP port the app tier listens on (used for ILB health check)"
  type        = number
  default     = 8080
}

# ── Health checks ─────────────────────────────────────────────────────────────

variable "web_health_check_path" {
  type    = string
  default = "/health"
}

variable "app_health_check_path" {
  type    = string
  default = "/health"
}

# ── Labels ────────────────────────────────────────────────────────────────────

variable "labels" {
  type    = map(string)
  default = {
    managed-by = "galleio"
    tier       = "three-tier-app"
  }
}
