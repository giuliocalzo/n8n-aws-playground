module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.0"

  name    = var.project_name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  enable_deletion_protection = false

  security_group_ingress_rules = merge(
    { for idx, cidr in var.allowed_cidr_blocks : "http_${idx}" => {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP from ${cidr}"
      cidr_ipv4   = cidr
    } },
    { for idx, cidr in var.allowed_cidr_blocks : "https_${idx}" => {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS from ${cidr}"
      cidr_ipv4   = cidr
    } },
    { for idx, cidr in data.github_ip_ranges.this.hooks_ipv4 : "github_hooks_${idx}" => {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "GitHub webhook ${cidr}"
      cidr_ipv4   = cidr
    } }
  )

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn = aws_acm_certificate.self_signed.arn
      forward = {
        target_group_key = "n8n"
      }
    }
  }

  target_groups = {
    n8n = {
      name_prefix = "n8n-"
      protocol    = "HTTP"
      port        = 5678
      target_type = "instance"
      target_id   = aws_instance.n8n.id

      deregistration_delay = 30

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        protocol            = "HTTP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 5
        matcher             = "200"
      }
    }
  }

  tags = local.tags
}
