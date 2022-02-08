# Environment for SG group
variable "env" {
  description = "Environment"
  type        = string
}
# Inbound/Outbound rules of Security group thats open port to CIDR like key --> value
variable "sg_port_cidr_app" {
  description = "Allowed EC2 ports"
  type        = map(any)
}
# Default inbound CIDR block
variable "default_cidr" {
  description = "Default CIDR block for IN/OUT traffic"
  type        = string
}

# Variables from another modules
# VPC id
variable "vpc_id" { type = any }
# Port for App
variable "app_port" { type = string }
