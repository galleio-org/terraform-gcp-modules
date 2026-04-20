# ─────────────────────────────────────────────────────────────────────────────
# Spoke VPC Module — Variables
# Galle.io Platform Model Factory  |  v1.0.0
# ─────────────────────────────────────────────────────────────────────────────

variable "project_id" {
  description = "GCP project ID for the spoke (service project)"
  type        = string
}

variable "network_name" {
  description = "Name of the spoke VPC network"
  type        = string
}

variable "description" {
  description = "Description for the VPC"
  type        = string
  default     = "Spoke VPC — workloads attached to hub via NCC"
}

variable "routing_mode" {
  description = "VPC routing mode. GLOBAL required when subnets span regions."
  type        = string
  default     = "GLOBAL"
}

variable "region" {
  description = "Primary region for this spoke"
  type        = string
  default     = "us-east4"
}

variable "environment" {
  description = "Environment label: dev, qa, prod, sandbox"
  type        = string
}

# ── Dynamic Subnets ──────────────────────────────────────────────────────────

variable "subnets" {
  description = "Map of subnets dynamically generated across any number of regions."
  type = map(object({
    region  = string
    cidr    = string
    purpose = optional(string, "") # e.g., "proxy" for regional managed proxy, or "" for compute
  }))
  default = {}
}

# ── GKE subnet (pre-allocated even before GKE is deployed) ───────────────────

variable "enable_gke_subnet" {
  description = "Create GKE node subnet with secondary ranges. Set true even before GKE deployment to pre-allocate CIDRs."
  type        = bool
  default     = true
}

variable "gke_subnet_cidr" {
  description = "GKE node pool subnet CIDR"
  type        = string
  default     = ""
}

variable "gke_pods_cidr" {
  description = "Secondary range CIDR for GKE pod IPs (172.16.0.0/14 recommended to avoid 10.x overlap)"
  type        = string
  default     = "172.16.0.0/14"
}

variable "gke_services_cidr" {
  description = "Secondary range CIDR for GKE service IPs"
  type        = string
  default     = "172.20.0.0/16"
}

variable "gke_pods_range_name" {
  description = "Name for the GKE pods secondary range"
  type        = string
  default     = ""  # Defaults to gke-pods-{environment}
}

variable "gke_services_range_name" {
  description = "Name for the GKE services secondary range"
  type        = string
  default     = ""  # Defaults to gke-services-{environment}
}

# ── NCC spoke attachment ──────────────────────────────────────────────────────

variable "attach_to_ncc" {
  description = "Create an NCC VPC spoke attachment to the hub. Requires ncc_hub_id."
  type        = bool
  default     = true
}

variable "ncc_hub_id" {
  description = "Resource ID of the NCC hub (google_network_connectivity_hub.hub.id)"
  type        = string
  default     = ""
}

variable "ncc_hub_project" {
  description = "Project ID where the NCC hub lives (typically the net-hub project)"
  type        = string
  default     = ""
}

variable "ncc_spoke_name" {
  description = "Name for the NCC VPC spoke. Defaults to {network_name}-spoke."
  type        = string
  default     = ""
}

# ── Labels ────────────────────────────────────────────────────────────────────

variable "labels" {
  description = "Labels applied to all resources"
  type        = map(string)
  default = {
    managed-by = "galleio"
    topology   = "hub-spoke"
    role       = "spoke"
  }
}
