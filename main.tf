provider "aws" {
  region  = var.region   # instant region
  profile = var.aws_user # default user
}

# Module thar create VPC with Public/Private Subnets and ALB
module "vpc" {
  source = "./modules/vpc"
  sg_alb = module.sg.sg_alb # Security Group for ALB
}

# Module for sreating Security Group that contains 2 SG for Web app and for ALB
module "sg" {
  source   = "./modules/Security-group"
  vpc_id   = module.vpc.vpc_id
  app_port = module.vpc.app_port
}

# Module for EC2 that created by ASG and for Bastion Host
module "ec2" {
  source            = "./modules/ec2"
  public_subnet     = module.vpc.public_subnet     # Take information about Public Subnet
  private_subnet_id = module.vpc.private_subnet_id # Take information about Private Subnet
  sg_app            = module.sg.sg_app             # Securit Group for Application
  sg_alb            = module.sg.sg_alb             # Securit Group for Application Load Balancer
  igw               = module.vpc.igw               # Output Internet Gateway
  availability_zone = module.vpc.availability_zone # Check AZ and attach it to instance
  alb_target        = module.vpc.alb_target        # ALB target group
}

# Module for ECR
module "ecr" {
  source = "./modules/ecr"
}
