# MIG Module (Managed Instance Group)

Creates a Managed Instance Group with autoscaling.

## Usage

```hcl
module "mig" {
  source           = "github.com/galleio/terraform-gcp-modules//modules/mig"
  project_id       = "my-project"
  name             = "web-mig"
  region           = "us-east4"
  subnet_self_link = module.subnet.subnet_self_link
  
  machine_type     = "e2-micro"
  min_replicas     = 2
  max_replicas     = 5
  target_cpu       = 0.6
  
  network_tags     = ["web-server"]
  
  startup_script   = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOF
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP Project ID | string | - | yes |
| name | MIG name | string | - | yes |
| region | Region | string | - | yes |
| subnet_self_link | Subnet self_link | string | - | yes |
| machine_type | Instance machine type | string | "e2-micro" | no |
| min_replicas | Minimum instances | number | 2 | no |
| max_replicas | Maximum instances | number | 5 | no |
| target_cpu | CPU target for autoscaling | number | 0.6 | no |
| network_tags | Network tags for instances | list(string) | [] | no |
| startup_script | Startup script content | string | "" | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_group | The instance group URL |
| instance_template | The instance template self_link |
