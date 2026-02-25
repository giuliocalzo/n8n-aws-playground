resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db/password"
  type  = "SecureString"
  value = random_password.db.result

  tags = local.tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.0"

  identifier = var.project_name

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 5

  db_name  = var.db_name
  username = var.db_username
  port     = 5432

  manage_master_user_password = false
  password_wo                 = random_password.db.result
  password_wo_version         = 1

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window = "Mon:03:00-Mon:04:00"
  backup_window      = "01:00-02:00"

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = true

  engine_lifecycle_support = "open-source-rds-extended-support-disabled"

  create_db_option_group    = false
  create_db_parameter_group = true

  tags = local.tags
}
