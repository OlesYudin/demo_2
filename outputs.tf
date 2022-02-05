# Output VPC CIDR
output "vpc_ip" {
  value = module.vpc.vpc_ip
}
# Output Public Elastic IP
output "eip_public_ip" {
  value = module.vpc.eip_public_ip
}
# Output DNS name of ALB
output "alb_dns" {
  value = module.vpc.alb_dns
}
# Output public IP of bastion Host
output "bastion_public_ip" {
  value = module.ec2.bastion_public_ip
}
# Output registry ID
output "regestry_id" {
  value = module.ecr.regestry_id
}
# Output registry URL
output "regestry_url" {
  value = module.ecr.regestry_url
}
