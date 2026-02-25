output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.dns_name
}

output "n8n_url" {
  description = "URL to access n8n (self-signed cert — browser will show a warning)"
  value       = "https://${module.alb.dns_name}"
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.db.db_instance_endpoint
}

output "ec2_instance_id" {
  description = "EC2 instance ID (use SSM Session Manager to connect)"
  value       = aws_instance.n8n.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "db_password_ssm_parameter" {
  description = "SSM Parameter Store path for the RDS password"
  value       = aws_ssm_parameter.db_password.name
}

