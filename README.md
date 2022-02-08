# <div align="center">Creating network infrastructure on AWS Cloud Provider using Terraform</div>

### Structure of modules:

1. [`ec2`](https://github.com/OlesYudin/demo_2/tree/main/modules/ec2 "ec2")
   - [Bastion Host](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/main.tf "Bastion Host") in public subnet of second AZ
   - [2 instance](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/asg.tf "2 instance") in private subnet in eache AZ
2. [`Security-group`](https://github.com/OlesYudin/demo_2/tree/main/modules/Security-group "Security-group")
   - [sg_app](https://github.com/OlesYudin/demo_2/blob/main/modules/Security-group/main.tf#:~:text=resource%20%22aws_security_group%22%20%22-,sg_app,-%22%20%7B "sg_app") open 22 port for SSH connection to instance
   - [sg_alb](https://github.com/OlesYudin/demo_2/blob/main/modules/Security-group/main.tf#:~:text=resource%20%22aws_security_group%22%20%22-,sg_alb,-%22%20%7B "sg_alb") open 80 port for HTTP to instance
3. [`vpc`](https://github.com/OlesYudin/demo_2/tree/main/modules/vpc "vpc")
   - [main.tf](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/main.tf "main.tf") create VPC with 2 public and 2 private subnets
   - [alb.tf](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/alb.tf "alb.tf") create Application Load Balancer for instance in private subnets
   - [nat.tf](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/nat.tf "nat.tf") create 1 Network Address Translation in first public subnet to route outbound traffic from instance in private subnet to Internet

### <div align="center">Infrastructure scheme</div>

<p align="center">
  <img src="https://github.com/OlesYudin/demo_2/blob/main/images/Network%20infrastructure%20DEMO_2.png" alt="Scheme of creation VPC in AWS"/>
</p>
