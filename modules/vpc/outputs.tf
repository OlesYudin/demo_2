output "vpc_id" {
  value = aws_vpc.vpc
}
output "vpc_ip" {
  value = aws_vpc.vpc.cidr_block
}
output "private_subnet_id" {
  value = aws_subnet.private_subnet.*.id
}
output "public_subnet_ip" {
  value = aws_subnet.public_subnet.*.cidr_block
}
output "private_subnet_ip" {
  value = aws_subnet.private_subnet.*.cidr_block
}
output "alb_dns" {
  value = aws_lb.alb.dns_name
}
output "public_subnet" {
  value = aws_subnet.public_subnet
}
output "igw" {
  value = aws_internet_gateway.igw
}
output "eip_public_ip" {
  value = aws_eip.nat_eip.public_ip
}
# Availability zone
output "availability_zone" {
  value = data.aws_availability_zones.available
}
# Default port 
output "app_port" {
  value = var.app_port
}
# ARN of Target Group
output "alb_target" {
  value = aws_lb_target_group.alb_target
}
