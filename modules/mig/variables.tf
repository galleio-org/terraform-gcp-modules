variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "The name of the MIG"
  type        = string
}

variable "region" {
  description = "The region for the MIG"
  type        = string
}

variable "subnet_self_link" {
  description = "The self_link of the subnet"
  type        = string
}

variable "machine_type" {
  description = "The machine type for instances"
  type        = string
  default     = "e2-micro"
}

variable "source_image" {
  description = "The source image for instances"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "network_tags" {
  description = "Network tags for instances"
  type        = list(string)
  default     = []
}

variable "startup_script" {
  description = "Startup script for instances"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "Service account email (leave empty for default)"
  type        = string
  default     = ""
}

variable "min_replicas" {
  description = "Minimum number of instances"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum number of instances"
  type        = number
  default     = 5
}

variable "target_cpu" {
  description = "Target CPU utilization for autoscaling (0.0 to 1.0)"
  type        = number
  default     = 0.6
}

variable "cooldown_period" {
  description = "Cooldown period in seconds"
  type        = number
  default     = 60
}

variable "health_check_path" {
  description = "HTTP path for health checks"
  type        = string
  default     = "/"
}
