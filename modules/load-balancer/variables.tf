variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "The name of the load balancer"
  type        = string
}

variable "instance_group" {
  description = "The URL of the instance group to use as backend"
  type        = string
}

variable "health_check" {
  description = "The self_link of the health check"
  type        = string
}

variable "enable_cdn" {
  description = "Enable Cloud CDN"
  type        = bool
  default     = false
}
