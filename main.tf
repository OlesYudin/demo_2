provider "aws" {
  region  = var.region   # instant region
  profile = var.aws_user # default user
}

# Module thar create VPC with: 
# - Public/Private Subnets; 
# - Routes to subnets;
# - ALB; 
# - NAT.
module "vpc" {
  source = "./modules/vpc"

  # Variables for VPC 
  env            = var.env
  app_port       = var.app_port
  cidr_vpc       = var.cidr_vpc
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
  default_cidr   = var.default_cidr

  # Data from another modules
  sg_alb = module.sg.sg_alb # Security Group for ALB
}

# Module for creating Security Group that contains 2 SG:
# - sg_alb (open 80 port);
# - sg_app (open 22 port).
module "sg" {
  source = "./modules/Security-group"

  # Default variables for Security Group
  env              = var.env
  sg_port_cidr_app = var.sg_port_cidr_app
  default_cidr     = var.default_cidr

  # Data from another modules
  vpc_id   = module.vpc.vpc_id
  app_port = module.vpc.app_port
}

# Module for EC2 that created: by ASG and for Bastion Host
# - Bastion Host (public subnet);
# - EC2 instance using Auto scaling group (private subnets).
module "ec2" {
  source = "./modules/ec2"

  # Default variables for EC2 module
  env            = var.env
  default_region = var.region
  instance_type  = var.instance_type

  # Data from another modules
  public_subnet     = module.vpc.public_subnet     # Take information about Public Subnet
  private_subnet_id = module.vpc.private_subnet_id # Take information about Private Subnet
  sg_app            = module.sg.sg_app             # Securit Group for Application
  sg_alb            = module.sg.sg_alb             # Securit Group for Application Load Balancer
  igw               = module.vpc.igw               # Output Internet Gateway
  availability_zone = module.vpc.availability_zone # Check AZ and attach it to instance
  alb_target        = module.vpc.alb_target        # ALB target group
}

# Module for ECR
# - Create ECR repository;
# - Make init build; (future)
# - Make CI/CD. (future)
module "ecr" {
  source = "./modules/ecr"

  # Default variables for ECR module
  region    = var.region
  app_name  = var.app_name
  image_tag = var.image_tag
}
