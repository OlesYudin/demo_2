# Environment
variable "env" {
  description = "Default environment"
  type        = string
}
# Region
variable "default_region" {
  description = "Default region for ec2"
  type        = string
}
# Instance type
variable "instance_type" {
  description = "Default instance type for ec2"
  type        = string
}

# Variables from another modules
# CIDR public subnet
variable "public_subnet" { type = list(any) }
# Private subnet ID
variable "private_subnet_id" { type = list(any) }
# ALB Target Group
variable "alb_target" { type = any }
# SG for SSH connection
variable "sg_app" { type = any }
# SG for HTTP
variable "sg_alb" { type = any }
# IGW
variable "igw" { type = any }
# Availability zone
variable "availability_zone" { type = any }
