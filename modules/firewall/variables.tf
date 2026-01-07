variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "network_self_link" {
  description = "The self_link of the VPC network"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network (used for rule naming)"
  type        = string
}

variable "enable_ssh" {
  description = "Create SSH firewall rule"
  type        = bool
  default     = true
}

variable "ssh_source_ranges" {
  description = "Source IP ranges for SSH access (default: IAP range)"
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "enable_http" {
  description = "Create HTTP firewall rule"
  type        = bool
  default     = false
}

variable "enable_https" {
  description = "Create HTTPS firewall rule"
  type        = bool
  default     = false
}

variable "enable_internal" {
  description = "Create internal communication firewall rule"
  type        = bool
  default     = true
}

variable "internal_ranges" {
  description = "Source IP ranges for internal communication"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "enable_health_check" {
  description = "Create health check firewall rule (for load balancers)"
  type        = bool
  default     = false
}

variable "target_tags" {
  description = "Network tags to apply firewall rules to"
  type        = list(string)
  default     = []
}
