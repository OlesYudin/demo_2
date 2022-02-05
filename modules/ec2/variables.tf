# Environment
variable "env" {
  default = "dev"
}
# Region
variable "default_region" {
  default = "us-east-2"
}
# Instance type
variable "instance_type" {
  default = "t2.micro"
}
# CIDR public subnet
variable "public_subnet" {
  type = list(any)
}
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
