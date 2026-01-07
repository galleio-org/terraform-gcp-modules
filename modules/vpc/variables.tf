variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "The name of the VPC network"
  type        = string
}

variable "region" {
  description = "The primary region for this VPC"
  type        = string
  default     = "us-east4"
}

variable "routing_mode" {
  description = "The network routing mode (REGIONAL or GLOBAL)"
  type        = string
  default     = "REGIONAL"
}
