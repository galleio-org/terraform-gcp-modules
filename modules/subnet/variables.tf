variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "The name of the subnet"
  type        = string
}

variable "region" {
  description = "The region for the subnet"
  type        = string
}

variable "network_self_link" {
  description = "The self_link of the VPC network"
  type        = string
}

variable "cidr" {
  description = "The IP CIDR range for the subnet"
  type        = string
}

variable "private_google_access" {
  description = "Enable private Google access for the subnet"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC flow logs for the subnet"
  type        = bool
  default     = false
}
