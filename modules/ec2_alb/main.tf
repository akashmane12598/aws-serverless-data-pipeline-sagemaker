locals {
  name_prefix = "${var.project_name}-${var.environment}"

  alb_name = "sensor-${var.environment}-alb"
  tg_name  = "sensor-${var.environment}-tg"
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "al2023-ami-*-x86_64"
    ]
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "${local.name_prefix}-ec2-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "ec2_s3_policy" {
  name = "${local.name_prefix}-ec2-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2_s3_role.name
}

resource "aws_instance" "springboot_ec2" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.ec2_security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  user_data_replace_on_change = true

  user_data = <<-EOF
            #!/bin/bash

            mkdir -p /home/ec2-user/app
            cd /home/ec2-user/app

            dnf install -y java-17-amazon-corretto

            aws s3 cp s3://${var.s3_bucket_name}/app/file-upload-app.jar /home/ec2-user/app/file-upload-app.jar

            cat > /home/ec2-user/app/application.properties <<'APP_PROPS'
            server.port=8080
            aws.region=us-east-1
            aws.s3.bucket-name=${var.s3_bucket_name}
            APP_PROPS

            pkill -f "file-upload-app.jar" || true

            nohup java -jar /home/ec2-user/app/file-upload-app.jar \
              --spring.config.location=file:/home/ec2-user/app/application.properties \
              > /home/ec2-user/app/app.log 2>&1 &
            EOF

  tags = {
    Name = "${local.name_prefix}-springboot-ec2"
  }
}

resource "aws_lb" "internal_alb" {
  name               = local.alb_name
  internal           = true
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.private_subnet_ids

  tags = {
    Name = "${local.name_prefix}-internal-alb"
  }
}

resource "aws_lb_target_group" "springboot_tg" {
  name     = local.tg_name
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${local.name_prefix}-springboot-tg"
  }
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.springboot_tg.arn
  target_id        = aws_instance.springboot_ec2.id
  port             = 8080
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.springboot_tg.arn
  }
}