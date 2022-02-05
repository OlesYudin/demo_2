# Add Elastic IP
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "nat_eip" {
  vpc = true # Use, if EIP should be in VPC

  tags = {
    Name = "EIP-${var.env}"
  }
}

# Create Network Address Translation
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id             # Attach to Elastic IP
  subnet_id     = aws_subnet.public_subnet[0].id # In what subnet will be NAT

  tags = {
    Name        = "NAT-GW-${var.env}"
    Environment = var.env
    AZ          = "${data.aws_availability_zones.available.names[0]}"
  }
}
