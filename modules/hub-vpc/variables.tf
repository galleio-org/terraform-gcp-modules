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

# ── Primary region subnets ──────────────────────────────────────────────────

variable "primary_region" {
  description = "Primary GCP region for the hub subnets"
  type        = string
  default     = "us-east4"
}

variable "nva_subnet_cidr" {
  description = "CIDR for the NVA/Firewall appliance subnet. Tiny /28 — only NVA LAN interfaces."
  type        = string
  default     = "10.0.0.0/28"
}

variable "services_subnet_cidr" {
  description = "CIDR for the shared services subnet (Bastion, DNS forwarder, internal tooling)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "psc_subnet_cidr" {
  description = "CIDR for Private Service Connect endpoints subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "proxy_subnet_cidr" {
  description = "CIDR for proxy-only subnet (required for Envoy-based L7 Internal LBs). Use /23 for large deployments."
  type        = string
  default     = "10.0.3.0/24"
}

# ── Secondary region (DR) subnets ───────────────────────────────────────────

variable "enable_secondary_region" {
  description = "Create mirrored hub subnets in a secondary region for DR"
  type        = bool
  default     = false
}

variable "secondary_region" {
  description = "Secondary GCP region for DR hub subnets"
  type        = string
  default     = "us-central1"
}

variable "secondary_services_subnet_cidr" {
  description = "CIDR for secondary-region services subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "secondary_proxy_subnet_cidr" {
  description = "CIDR for secondary-region proxy-only subnet"
  type        = string
  default     = "10.10.252.0/23"
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
