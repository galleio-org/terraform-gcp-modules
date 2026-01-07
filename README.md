# GalleIO Terraform GCP Modules

Verified, production-ready Terraform modules for Google Cloud Platform.

These modules are used by the GalleIO AI agents to generate reliable infrastructure code.

## Available Modules

| Module | Description | Status |
|--------|-------------|--------|
| [vpc](./modules/vpc) | VPC Network | ✅ Ready |
| [subnet](./modules/subnet) | Subnet with optional private Google access | ✅ Ready |
| [firewall](./modules/firewall) | Firewall rules (SSH, HTTP, HTTPS, Internal) | ✅ Ready |
| [mig](./modules/mig) | Managed Instance Group with Autoscaling | ✅ Ready |
| [load-balancer](./modules/load-balancer) | HTTP(S) Load Balancer | ✅ Ready |
| [gke](./modules/gke) | GKE Autopilot Cluster | ✅ Ready |

## Usage

Reference modules from this repository:

```hcl
module "vpc" {
  source     = "github.com/galleio/terraform-gcp-modules//modules/vpc"
  project_id = var.project_id
  name       = "my-vpc"
  region     = "us-east4"
}
```

## For GalleIO Agents (Seth)

When generating Terraform code, use ONLY these module sources:
- `github.com/galleio/terraform-gcp-modules//modules/vpc`
- `github.com/galleio/terraform-gcp-modules//modules/subnet`
- `github.com/galleio/terraform-gcp-modules//modules/firewall`
- `github.com/galleio/terraform-gcp-modules//modules/mig`
- `github.com/galleio/terraform-gcp-modules//modules/load-balancer`
- `github.com/galleio/terraform-gcp-modules//modules/gke`

See individual module READMEs for exact input/output interfaces.
