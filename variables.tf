# Default for all infrastructure
# Default region where will be created infrastructure
variable "region" {}
# Default user that will push infrastructure to AWS
variable "aws_user" {}
# Default environments
variable "env" {}

# VPC
# Default VPC CIDR
variable "cidr_vpc" {}
# Default public subnets for VPC
variable "public_subnet" {}
# Default private subnets for VPC
variable "private_subnet" {}
# Default CIDR for routing traffic
variable "default_cidr" {}

# SG
# Port for Application (ALB)
variable "app_port" {}
# Open ports to CIDR
variable "sg_port_cidr_app" {}

# EC2
# Default instance type
variable "instance_type" {}


# ECR
# Name of container for App
variable "app_name" {}
# Container image tag
variable "image_tag" {}
