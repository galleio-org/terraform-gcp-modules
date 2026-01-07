# GKE Module

Creates a GKE Autopilot cluster.

## Usage

```hcl
module "gke" {
  source             = "github.com/galleio/terraform-gcp-modules//modules/gke"
  project_id         = "my-project"
  name               = "my-cluster"
  region             = "us-east4"
  network_self_link  = module.vpc.network_self_link
  subnet_self_link   = module.subnet.subnet_self_link
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| name | Cluster name | string | - | yes |
| region | Region | string | - | yes |
| network_self_link | VPC self_link | string | - | yes |
| subnet_self_link | Subnet self_link | string | - | yes |
| enable_private_nodes | Use private nodes | bool | true | no |
| master_authorized_networks | Allowed CIDRs for master | list(object) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | The name of the cluster |
| cluster_endpoint | The endpoint of the cluster |
| cluster_ca_certificate | The CA certificate of the cluster |
