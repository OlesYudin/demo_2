# public SSH key for connection to Bastion Host in public subnet
# Add key.pub to .gitignore
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = file("./modules/ec2/SSH-key/bastion.pub")
}
# public SSH key for connection to EC2 in private subnet
resource "aws_key_pair" "asg_ec2_key" {
  key_name   = "asg_ec2_key" # TODO: Rename key as file name of public key 
  public_key = file("./modules/ec2/SSH-key/private_ec2.pub")
}
