resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.ubuntu.id                # ubuntu 16.04
  instance_type          = var.instance_type                     # instant params
  subnet_id              = var.public_subnet[1].id               # attach EC2 to public subnet in us-east-2b
  vpc_security_group_ids = var.sg_app.*.id                       # attach sec group
  key_name               = aws_key_pair.bastion_key.key_name     # key for SSH connection to Bastion
  user_data              = file("./modules/ec2/shell/apache.sh") # install apache

  tags = {
    Name        = "Bastion-Host-${var.availability_zone.names[1]}"
    AZ          = "${var.availability_zone.names[1]}"
    Owner       = "Student"
    Environment = var.env
  }
}


# resource "aws_instance" "webserver" {
#   count                  = length(var.private_subnet_id)         # count numbers of private subnets
#   ami                    = data.aws_ami.ubuntu.id                # ubuntu 16.04
#   instance_type          = var.instance_type                     # instant params
#   subnet_id              = var.private_subnet_id[count.index]    # attach EC2 to subnet
#   vpc_security_group_ids = var.sg_app.*.id                       # attach sec group
#   key_name               = var.ssh_key                           # key for SSH connection
#   user_data              = file("./modules/ec2/shell/apache.sh") # install apache

#   tags = {
#     Name        = "Webserver-${count.index + 1}"
#     AZ          = "${var.availability_zone.names[count.index]}"
#     Owner       = "Student"
#     Environment = var.env
#   }
# }
