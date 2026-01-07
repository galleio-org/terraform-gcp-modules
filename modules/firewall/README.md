# Firewall Module

Creates common firewall rules for a VPC.

## Usage

```hcl
module "firewall" {
  source            = "github.com/galleio/terraform-gcp-modules//modules/firewall"
  project_id        = "my-project"
  network_self_link = module.vpc.network_self_link
  network_name      = module.vpc.network_name
  
  enable_ssh        = true
  ssh_source_ranges = ["35.235.240.0/20"]  # IAP for SSH
  
  enable_http       = true
  enable_https      = true
  
  enable_internal   = true
  internal_ranges   = ["10.0.0.0/8"]
  
  target_tags       = ["web-server"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| network_self_link | VPC self_link | string | - | yes |
| network_name | VPC name (for rule naming) | string | - | yes |
| enable_ssh | Create SSH rule | bool | true | no |
| ssh_source_ranges | SSH source IPs | list(string) | ["35.235.240.0/20"] | no |
| enable_http | Create HTTP rule | bool | false | no |
| enable_https | Create HTTPS rule | bool | false | no |
| enable_internal | Create internal rule | bool | true | no |
| internal_ranges | Internal source IPs | list(string) | ["10.0.0.0/8"] | no |
| target_tags | Tags to apply rules to | list(string) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| ssh_firewall_name | Name of SSH firewall rule |
| http_firewall_name | Name of HTTP firewall rule |
| https_firewall_name | Name of HTTPS firewall rule |
