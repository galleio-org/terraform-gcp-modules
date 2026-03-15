# Galle.io Example: Web App with Load Balancer
# This example creates a VPC, subnet, firewall, MIG, and Load Balancer

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-east4"
}

variable "name" {
  description = "Application name"
  type        = string
  default     = "webapp"
}

# VPC
module "vpc" {
  source     = "../modules/vpc"
  project_id = var.project_id
  name       = "${var.name}-vpc"
  region     = var.region
}

# Subnet
module "subnet" {
  source            = "../modules/subnet"
  project_id        = var.project_id
  name              = "${var.name}-subnet"
  region            = var.region
  network_self_link = module.vpc.network_self_link
  cidr              = "10.0.1.0/24"
}

# Firewall
module "firewall" {
  source            = "../modules/firewall"
  project_id        = var.project_id
  network_self_link = module.vpc.network_self_link
  network_name      = module.vpc.network_name
  
  enable_ssh          = true
  enable_http         = true
  enable_health_check = true
  target_tags         = ["web-server"]
}

# Managed Instance Group
module "mig" {
  source           = "../modules/mig"
  project_id       = var.project_id
  name             = "${var.name}-mig"
  region           = var.region
  subnet_self_link = module.subnet.subnet_self_link
  
  machine_type = "e2-micro"
  min_replicas = 2
  max_replicas = 5
  target_cpu   = 0.6
  
  network_tags = ["web-server"]
  
  startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    echo "<h1>Hello from Galle.io - $(hostname)</h1>" > /var/www/html/index.html
    systemctl start nginx
  EOF
}

# Load Balancer
module "lb" {
  source         = "../modules/load-balancer"
  project_id     = var.project_id
  name           = "${var.name}-lb"
  instance_group = module.mig.instance_group
  health_check   = module.mig.health_check_self_link
}

# Outputs
output "load_balancer_ip" {
  description = "Access your app at this IP"
  value       = module.lb.lb_ip_address
}

output "load_balancer_url" {
  description = "Access your app at this URL"
  value       = module.lb.lb_url
}

output "vpc_name" {
  description = "VPC name"
  value       = module.vpc.network_name
}
