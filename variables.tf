# Default region where will be created infrastructure
variable "region" {
  description = "Default region"
  type        = string
  default     = "us-east-2"
}
# Default user that will push infrastructure to AWS
variable "aws_user" {
  description = "Default AWS user that make terraform command"
  type        = string
  default     = "student"
}
# Default environments
variable "env" {
  description = "Default environments"
  type        = string
  default     = "dev"
}
# Default CIDR for routing traffic
variable "default_cidr" {
  description = "Default CIDR for route traffic and for IN/OUT traffic"
  type        = string
  default     = "0.0.0.0/0"
}
