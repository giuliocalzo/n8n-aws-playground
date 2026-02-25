# n8n Self-Hosted on AWS

Terraform infrastructure to deploy [n8n](https://n8n.io) on AWS with VPC, ALB, EC2, and RDS PostgreSQL.

## Architecture

```
Internet → ALB (HTTPS, self-signed) → EC2 / Docker (private) → RDS PostgreSQL (database)
```

- VPC with public, private, and database subnets across 2 AZs
- ALB with self-signed TLS certificate (HTTP redirects to HTTPS)
- ALB security group restricts access to `allowed_cidr_blocks` + GitHub webhook IPs
- EC2 runs n8n via Docker in a private subnet (SSM Session Manager enabled)
- RDS PostgreSQL in isolated database subnets with SSL enabled
- Secrets (DB password, n8n encryption key) auto-generated and stored in SSM Parameter Store

## Getting Started

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars

# Or override via environment variables
export TF_VAR_aws_region="eu-west-1"

terraform init
terraform plan
terraform apply
```

Once applied, open the `n8n_url` output to access n8n. The ALB uses a self-signed certificate so browsers will show a warning.

See [`terraform/README.md`](terraform/README.md) for full variable reference, architecture diagram, and operational details.

## Recommended Workflows

Once n8n is up and running, consider setting up [Automated Daily Workflow Backup to GitHub](https://n8n.io/workflows/4064-automated-daily-workflow-backup-to-github/) to version-control your n8n workflows and protect against data loss.

## License

[WTFPL](LICENSE)
