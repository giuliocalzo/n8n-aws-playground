data "aws_availability_zones" "available" {}

data "github_ip_ranges" "this" {}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = merge(var.tags, {
    Project   = var.project_name
    ManagedBy = "terraform"
  })
}
