# Default region for AWS provider
variable "region" {
  type    = string
  default = "us-east-2"
}
# Default user
variable "aws_user" {
  type    = string
  default = "student"
}
# Application name
variable "app_name" {
  type    = string
  default = "password-container"
}
# Docker image tag
variable "image_tag" {
  type    = string
  default = "latest"
}
