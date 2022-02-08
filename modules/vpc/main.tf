resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_vpc
  instance_tenancy = "default"
  # Стандартные настройки при создании VPC ручками
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "my-${var.env}-VPC"
    Owner = "Student"
  }
}

resource "aws_subnet" "public_subnet" {
  count  = length(var.public_subnet) # count leangtn. In our case 2 Subnets
  vpc_id = aws_vpc.vpc.id            # Connect our VPC with subnet
  # (https://www.terraform.io/language/functions/cidrsubnet)
  # Give subnets IP from VPC range.
  cidr_block              = var.public_subnet[count.index]                           # 172.31.0.0/16 ==> 172.31.X.X/24 
  availability_zone       = data.aws_availability_zones.available.names[count.index] # For 2 subnets give available zone
  map_public_ip_on_launch = true                                                     # Give public IP

  tags = {
    Name              = "Public-Subnet-${var.env}-${count.index + 1}"
    Availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Connect our VPC to the Internet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "IGW-${var.env}"
    Description = "Internet Gateway for VPC"
    Environment = "${var.env}"
  }
}

# Route table from Internet to public subnets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.default_cidr            # Allow all to IN/OUT traffic
    gateway_id = aws_internet_gateway.igw.id # Attach to IGW and Internet will work
  }

  tags = {
    Name = "PublicRouteTable-${var.env}"
  }
}

resource "aws_route_table_association" "publicrouteAssociation" {
  count          = length(var.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.publicroute.id
}


# Private Subnet
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "Private-Subnet-${var.env}-${count.index + 1}"
    Environment = "${var.env}"
    AZ          = "${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Route table from Internet to private subnets 
resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.default_cidr       # Allow all to IN/OUT traffic
    nat_gateway_id = aws_nat_gateway.nat.id # Attach to NAT
  }

  tags = {
    Name        = "PrivateRouteTable-${var.env}"
    Environment = var.env
  }
}

resource "aws_route_table_association" "privaterouteAssociation" {
  count          = length(var.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.privateroute.id
}
