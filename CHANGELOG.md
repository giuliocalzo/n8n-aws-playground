# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0]

### Added

- Initial Terraform infrastructure for n8n on AWS
- VPC with public, private, and database subnets across 2 AZs using `terraform-aws-modules/vpc/aws` ~> 6.0
- Application Load Balancer using `terraform-aws-modules/alb/aws` ~> 10.0
- Self-signed TLS certificate for HTTPS with automatic HTTP-to-HTTPS redirect
- EC2 instance running n8n via Docker with systemd service management
- RDS PostgreSQL database using `terraform-aws-modules/rds/aws` ~> 7.0
- Auto-generated DB password stored in SSM Parameter Store as SecureString
- Auto-generated `N8N_ENCRYPTION_KEY` stored in SSM Parameter Store as SecureString
- EC2 fetches secrets from SSM at boot (no plaintext secrets in user data)
- IAM role with SSM Session Manager for EC2 access (no bastion/SSH needed)
- SSL enabled on the n8n-to-RDS connection
- ALB security group restricted to configurable `allowed_cidr_blocks`
- GitHub webhook IPv4 ranges dynamically added to ALB security group via `github_ip_ranges` data source
- Configurable `ec2_root_volume_size` variable
- n8n data persisted to `/opt/n8n/data` host-bind mount
- `WEBHOOK_URL` and `N8N_PROXY_HOPS` configured for ALB proxy setup
- `.gitignore` for Terraform state, plans, and tfvars
- WTFPL license
