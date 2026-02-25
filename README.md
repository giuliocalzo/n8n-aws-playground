# n8n Self-Hosted on AWS

Terraform infrastructure to deploy [n8n](https://n8n.io) on AWS with VPC, ALB, EC2, and RDS PostgreSQL.

## Architecture

```
Internet → ALB (public) → EC2 / Docker (private) → RDS PostgreSQL (database)
```

All resources live inside a VPC with public, private, and database subnets across two availability zones. The DB password is auto-generated and stored in SSM Parameter Store.

## Getting Started

```bash
cd terraform

# Override any variable via TF_VAR_ environment variables
export TF_VAR_aws_region="eu-west-1"

terraform init
terraform plan
terraform apply
```

Once applied, open the `n8n_url` output to access n8n. The ALB uses a self-signed certificate so browsers will show a warning.

See [`terraform/README.md`](terraform/README.md) for full variable reference and architecture details.

## Recommended Workflows

Once n8n is up and running, consider setting up [Automated Daily Workflow Backup to GitHub](https://n8n.io/workflows/4064-automated-daily-workflow-backup-to-github/) to version-control your n8n workflows and protect against data loss.
