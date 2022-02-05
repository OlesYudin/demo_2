# Environment
variable "env" {
  default = "dev"
}
# VPC
variable "cidr_vpc" {
  description = "CIDR of VPC"
  type        = string
  default     = "172.31.0.0/16"
}
# Public Subnet
variable "public_subnet" {
  type = list(string)
  default = [
    "172.31.1.0/24",
    "172.31.2.0/24"
  ]
}
# Private Subnet
variable "private_subnet" {
  type = list(string)
  default = [
    "172.31.11.0/24",
    "172.31.12.0/24"
  ]
}
# Default port for APP
variable "app_port" {
  type    = string
  default = 80
}
# SG for ALB
variable "sg_alb" { type = any }
