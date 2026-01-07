variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "The region for the cluster"
  type        = string
}

variable "network_self_link" {
  description = "The self_link of the VPC network"
  type        = string
}

variable "subnet_self_link" {
  description = "The self_link of the subnet"
  type        = string
}

variable "enable_private_nodes" {
  description = "Enable private nodes (no external IPs)"
  type        = bool
  default     = true
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of authorized networks for master access"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "release_channel" {
  description = "GKE release channel (REGULAR, RAPID, STABLE)"
  type        = string
  default     = "REGULAR"
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}
