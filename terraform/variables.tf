variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "n8n"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the n8n server"
  type        = string
  default     = "t3.small"
}

variable "ec2_root_volume_size" {
  description = "Size in GB of the EC2 root volume"
  type        = number
  default     = 100
}

variable "ec2_key_name" {
  description = "Name of an existing EC2 key pair for SSH access (optional)"
  type        = string
  default     = null
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_name" {
  description = "Name of the PostgreSQL database for n8n"
  type        = string
  default     = "n8n"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "n8n"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for the RDS instance"
  type        = number
  default     = 20
}

variable "n8n_version" {
  description = "n8n Docker image tag"
  type        = string
  default     = "latest"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB (default: open to internet)"
  type        = list(string)
  default     = ["165.1.150.138/32"]
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
