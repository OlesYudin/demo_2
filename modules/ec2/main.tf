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
