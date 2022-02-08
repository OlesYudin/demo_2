# Environment
variable "env" {
  description = "Environment"
  type        = string
}
# Default port for APP
variable "app_port" {
  description = "Port that will be open for listen APP"
  type        = string
}
# VPC
variable "cidr_vpc" {
  description = "CIDR of VPC"
  type        = string
}
# Public Subnet
variable "public_subnet" {
  description = "Public CIDR-block for subnets"
  type        = list(string)
}
# Private Subnet
variable "private_subnet" {
  description = "Private CIDR-block for subnets"
  type        = list(string)
}
# Default CIDR block for route traffic
variable "default_cidr" {
  description = "Default CIDR block for route traffic"
  type        = string
}


# Get variables from another modules
# SG for ALB
variable "sg_alb" { type = any }
