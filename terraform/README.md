# n8n on AWS — Terraform

Deploy [n8n](https://n8n.io) on AWS with an Application Load Balancer, EC2 instance, and RDS PostgreSQL database.

## Architecture

```
Internet
   │
   ▼
┌──────────────────────────── VPC (10.0.0.0/16) ─────────────────────────────┐
│                                                                             │
│  ┌─────────── Public Subnets ───────────┐                                   │
│  │  ALB (HTTPS :443) ──► Target Group   │                                   │
│  └──────────────────────────────────────┘                                   │
│            │                                                                │
│            ▼                                                                │
│  ┌─────────── Private Subnets ──────────┐   ┌── Database Subnets ────────┐  │
│  │  EC2 (n8n Docker :5678)              │──►│  RDS PostgreSQL :5432      │  │
│  └──────────────────────────────────────┘   └────────────────────────────┘  │
│            │                                                                │
│            ▼                                                                │
│       NAT Gateway (outbound internet)                                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Components:**

| Resource | Module / Resource | Purpose |
|----------|-------------------|---------|
| VPC | `terraform-aws-modules/vpc/aws` ~> 6.0 | Networking with public, private, and database subnets across 2 AZs |
| ALB | `terraform-aws-modules/alb/aws` ~> 10.0 | HTTPS load balancer with self-signed certificate |
| EC2 | `aws_instance` | Runs n8n via Docker in a private subnet |
| RDS | `terraform-aws-modules/rds/aws` ~> 7.0 | PostgreSQL database in database subnets |
| TLS/ACM | `tls_self_signed_cert` + `aws_acm_certificate` | Self-signed TLS certificate imported into ACM |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.11
- AWS credentials configured (`aws configure` or environment variables)
- An AWS account with permissions to create VPC, EC2, RDS, ALB, and IAM resources

## Quick Start

```bash
cd terraform

# Copy and edit the variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars to your liking (DB password is auto-generated)

terraform init
terraform plan
terraform apply
```

After `apply` completes, the `n8n_url` output contains the URL to access n8n.

## Connecting to the EC2 Instance

The instance has SSM Session Manager enabled (no SSH key or bastion needed):

```bash
aws ssm start-session --target <ec2_instance_id>
```

Check n8n status:

```bash
sudo systemctl status n8n
sudo docker logs n8n --tail 50
```

## HTTPS

The ALB is configured with a self-signed TLS certificate. HTTP traffic on port 80 is automatically redirected to HTTPS on port 443. Browsers will show a certificate warning since the cert is not issued by a trusted CA — this is expected for internal/dev use.

To use a trusted certificate, replace the `certificate_arn` in `alb.tf` with your own ACM certificate ARN.

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `aws_region` | AWS region | `eu-west-1` |
| `project_name` | Name prefix for resources | `n8n` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `ec2_instance_type` | EC2 instance type | `t3.small` |
| `ec2_key_name` | EC2 key pair name (optional) | `null` |
| `db_instance_class` | RDS instance class | `db.t4g.micro` |
| `db_name` | PostgreSQL database name | `n8n` |
| `db_username` | PostgreSQL master username | `n8n` |
| `db_allocated_storage` | RDS storage in GB | `20` |
| `n8n_version` | n8n Docker image tag | `latest` |
| `allowed_cidr_blocks` | CIDRs allowed to reach ALB | `["0.0.0.0/0"]` |
| `tags` | Additional resource tags | `{}` |

## Cleanup

```bash
terraform destroy
```
