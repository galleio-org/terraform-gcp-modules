# Load Balancer Module

Creates an HTTP(S) Load Balancer with a backend service.

## Usage

```hcl
module "lb" {
  source         = "github.com/galleio/terraform-gcp-modules//modules/load-balancer"
  project_id     = "my-project"
  name           = "web-lb"
  instance_group = module.mig.instance_group
  health_check   = module.mig.health_check_self_link
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| name | Load balancer name | string | - | yes |
| instance_group | Backend instance group URL | string | - | yes |
| health_check | Health check self_link | string | - | yes |
| enable_cdn | Enable Cloud CDN | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| lb_ip_address | The external IP of the load balancer |
| lb_url | The URL to access the load balancer |
