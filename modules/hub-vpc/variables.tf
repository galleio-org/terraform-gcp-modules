# ─────────────────────────────────────────────────────────────────────────────
# Hub VPC Module — Variables
# Galle.io Platform Model Factory  |  v1.0.0
# ─────────────────────────────────────────────────────────────────────────────

variable "project_id" {
  description = "GCP project ID hosting the Hub VPC (typically the net-hub project)"
  type        = string
}

variable "network_name" {
  description = "Name of the hub VPC network"
  type        = string
  default     = "hub-vpc"
}

variable "description" {
  description = "Human-readable description for the VPC"
  type        = string
  default     = "Hub VPC — centralized NAT, DNS, PSC, bastion, NVA insertion point"
}

variable "routing_mode" {
  description = "VPC routing mode. GLOBAL is required for hub-spoke (routes propagate across regions)"
  type        = string
  default     = "GLOBAL"
}

# ── Dynamic Subnets ──────────────────────────────────────────────────────────

variable "subnets" {
  description = "Map of subnets dynamically generated across any number of regions."
  type = map(object({
    region  = string
    cidr    = string
    purpose = optional(string, "") # e.g., "psc", "nva", "proxy", "services"
  }))
  default = {}
}

# ── Cloud NAT ───────────────────────────────────────────────────────────────

variable "enable_cloud_nat" {
  description = "Create Cloud NAT for private instance internet egress via the hub"
  type        = bool
  default     = true
}

variable "nat_router_name" {
  description = "Name of the Cloud Router for NAT"
  type        = string
  default     = ""  # Defaults to {network_name}-router-{region}
}

variable "nat_name" {
  description = "Name of the Cloud NAT resource"
  type        = string
  default     = ""  # Defaults to {network_name}-nat-{region}
}

variable "nat_min_ports_per_vm" {
  description = "Minimum number of ports per VM for Cloud NAT"
  type        = number
  default     = 64
}

# ── Labels ───────────────────────────────────────────────────────────────────

variable "labels" {
  description = "Labels applied to all resources in this module"
  type        = map(string)
  default = {
    managed-by = "galleio"
    topology   = "hub-spoke"
    role       = "hub"
  }
}
