# Subnet Module

Creates a subnet within a VPC network.

## Usage

```hcl
module "subnet" {
  source            = "github.com/galleio/terraform-gcp-modules//modules/subnet"
  project_id        = "my-project"
  name              = "web-subnet"
  region            = "us-east4"
  network_self_link = module.vpc.network_self_link
  cidr              = "10.0.1.0/24"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| name | Subnet name | string | - | yes |
| region | Region | string | - | yes |
| network_self_link | VPC self_link | string | - | yes |
| cidr | IP CIDR range | string | - | yes |
| private_google_access | Enable private Google access | bool | true | no |
| enable_flow_logs | Enable VPC flow logs | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| subnet_name | The name of the subnet |
| subnet_self_link | The self_link of the subnet |
| subnet_id | The ID of the subnet |
