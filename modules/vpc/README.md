# VPC Module

Creates a VPC network in Google Cloud.

## Usage

```hcl
module "vpc" {
  source     = "github.com/galleio/terraform-gcp-modules//modules/vpc"
  project_id = "my-project"
  name       = "my-vpc"
  region     = "us-east4"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| name | VPC name | string | - | yes |
| region | Primary region | string | "us-east4" | no |
| routing_mode | REGIONAL or GLOBAL | string | "REGIONAL" | no |

## Outputs

| Name | Description |
|------|-------------|
| network_name | The name of the VPC |
| network_self_link | The self_link of the VPC |
| network_id | The ID of the VPC |
