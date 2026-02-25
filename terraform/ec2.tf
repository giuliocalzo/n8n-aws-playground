resource "aws_iam_role" "n8n" {
  name_prefix = "${var.project_name}-ec2-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.n8n.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "read_ssm_params" {
  name = "${var.project_name}-read-ssm-params"
  role = aws_iam_role.n8n.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Resource = aws_ssm_parameter.db_password.arn
    }]
  })
}

resource "aws_iam_instance_profile" "n8n" {
  name_prefix = "${var.project_name}-"
  role        = aws_iam_role.n8n.name
}

resource "aws_instance" "n8n" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.ec2_instance_type
  subnet_id              = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.n8n.name
  key_name               = var.ec2_key_name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    aws_region            = var.aws_region
    db_host               = module.db.db_instance_address
    db_port               = module.db.db_instance_port
    db_name               = var.db_name
    db_user               = var.db_username
    db_password_ssm_param = aws_ssm_parameter.db_password.name
    n8n_version           = var.n8n_version
  })

  tags = merge(local.tags, { Name = "${var.project_name}-server" })
}
