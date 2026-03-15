variable "project_id" {
  description = "GCP project ID for the NCC hub (net-hub project)"
  type        = string
}

variable "hub_name" {
  description = "Name of the NCC hub"
  type        = string
}

variable "hub_description" {
  description = "Description for the NCC hub"
  type        = string
  default     = "NCC Hub — centralized network connectivity for hub-and-spoke topology"
}

variable "vpc_spokes" {
  description = "List of VPC spoke configurations to attach to this NCC hub"
  type = list(object({
    name        = string            # NCC spoke resource name
    network_uri = string            # VPC self_link
    location    = optional(string, "global")
    exclude_export_ranges = optional(list(string), [])
  }))
  default = []
}

variable "vpn_spokes" {
  description = "List of VPN tunnel spoke configurations (for on-prem connectivity)"
  type = list(object({
    name        = string
    location    = string            # Region of the HA VPN gateway
    vpn_tunnels = list(object({
      uri = string                  # google_compute_vpn_tunnel self_link
    }))
    site_to_site_data_transfer = optional(bool, true)
  }))
  default = []
}

variable "labels" {
  type    = map(string)
  default = {
    managed-by = "galleio"
    topology   = "hub-spoke"
  }
}
