# Security group for EC2 instance
resource "aws_security_group" "sg_app" {
  name        = "SG-SSH"
  description = "Security group for SSH connection to EC2 instance"
  vpc_id      = var.vpc_id.id

  # Inbound rules for 22ports
  # Open 22 to my IP and my VPC
  dynamic "ingress" {
    for_each = var.sg_port_cidr_app
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
    }
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default_cidr]
  }

  tags = {
    Name        = "SG-SSH-${var.env}"
    Environment = var.env
  }
}


# Security group for ALB
resource "aws_security_group" "sg_alb" {
  name        = "SG-HTTP"
  description = "Security group for HTTP connection to EC2 instance"
  vpc_id      = var.vpc_id.id

  # Inbound rules for app port
  ingress {
    description = "HTTP for ALB"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = [var.default_cidr]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default_cidr]
  }

  tags = {
    Name        = "SG-HTTP-${var.env}"
    Environment = var.env
  }
}
