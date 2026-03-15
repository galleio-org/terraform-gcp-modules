variable "project_id" {
  description = "GCP project hosting the bastion (typically the net-hub project)"
  type        = string
}

variable "name" {
  description = "Bastion instance name"
  type        = string
  default     = "bastion"
}

variable "region" {
  description = "Region for the bastion host"
  type        = string
  default     = "us-east4"
}

variable "zone" {
  description = "Zone for the bastion instance"
  type        = string
  default     = "us-east4-a"
}

variable "network" {
  description = "VPC network name or self_link (hub services network)"
  type        = string
}

variable "subnet" {
  description = "Subnet self_link for the bastion (hub services subnet)"
  type        = string
}

variable "machine_type" {
  description = "Bastion machine type. e2-micro is sufficient for SSH tunnelling only."
  type        = string
  default     = "e2-micro"
}

variable "image" {
  description = "Boot disk image (Shielded VM)"
  type        = string
  default     = "projects/debian-cloud/global/images/family/debian-12"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "service_account_roles" {
  description = "Additional IAM roles to grant to the bastion service account"
  type        = list(string)
  default     = ["roles/logging.logWriter", "roles/monitoring.metricWriter"]
}

variable "allowed_source_ranges" {
  description = "Additional source IP ranges allowed SSH access (on top of IAP 35.235.240.0/20)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Network tags applied to the bastion instance"
  type        = list(string)
  default     = ["bastion", "iap-ssh"]
}

variable "labels" {
  type    = map(string)
  default = {
    managed-by = "galleio"
    role       = "bastion"
  }
}
