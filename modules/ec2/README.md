# <div align="center">Creating EC2 instance</div>

Creating AWS EC2 instance in 2 private subnets and bastion host with [security group](https://github.com/OlesYudin/demo_2/tree/main/modules/Security-group "security group").

## Description of EC2:

1. [Bastion Host](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/main.tf#:~:text=Blame-,resource%20%22aws_instance%22%20%22bastion%22%20%7B,%7D,-%C2%A9%202022%20GitHub%2C%20Inc "Bastion Host") in [Public Subnet](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/variables.tf#:~:text=%22-,172.31.2.0/24,-%22 "Public Subnet")
2. 2 EC2 instance in Private Subnet that created by [ASG](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/asg.tf "ASG")

### <div align="center">Create keys for SSH connection</div>

<p align="center">
  <img src="https://github.com/OlesYudin/demo_2/blob/main/images/SSH%20connections.png" alt="Create keys for SSH connection"/>
</p>

## Connection to EC2 in Private Subnet:

1. Local. Generate 2 ssh-keys (1. key for bastion, 2. key for instance in private subnet) `ssh-keygen -t ed25519 -b 512 -f ~/.ssh/key_name -C 'Comment in public key'`
2. Input public keys to folder [SSH-key](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/SSH-key/ "SSH-key")
3. Do `terraform apply`
4. Connect to Bastion Host use your private key
5. Copy private key from local machine to Bastion Host
6. Connect to instance `ssh -i ~/.ssh/key_name ubuntu@private_ip` (As a default username: **ubuntu**)

## Settings of Bastion Host:

| Value                  | Default                                                                                                                                                                                           |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Region                 | us-east-2b                                                                                                                                                                                        |
| AMI                    | [Ubuntu 16.04 Server](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/data.tf "Ubuntu 16.04 Server")                                                                                    |
| Instance type          | t2.micro                                                                                                                                                                                          |
| Environment            | [Developer](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/variables.tf#:~:text=variable%20%22env%22%20%7B,%7D "Developer")                                                            |
| Count                  | 1                                                                                                                                                                                                 |
| Key for SSH connection | Generate yourselve and write public key to [SSH-key](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/SSH-key/ "SSH-key")                                                                |
| Download packages      | nothing                                                                                                                                                                                           |
| Subnet                 | Create in [VPC](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/variables.tf#:~:text=variable%20%22cidr_vpc%22%20%7B,%7D "VPC") module                                                  |
| Security Group         | Open [22](https://github.com/OlesYudin/demo_2/blob/main/modules/Security-group/main.tf#:~:text=Blame-,%23%20Security%20group%20for%20EC2%20instance,%7D,-%23%20Security%20group%20for "22") ports |

## Settings of instance in private subnets:

| Value                  | Default                                                                                                                                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Region                 | us-east-2(a,b)                                                                                                                                                                                                  |
| AMI                    | [Ubuntu 16.04 Server](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/data.tf "Ubuntu 16.04 Server")                                                                                                  |
| Instance type          | t2.micro                                                                                                                                                                                                        |
| Environment            | [Developer](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/variables.tf#:~:text=variable%20%22env%22%20%7B,%7D "Developer")                                                                          |
| Count                  | 1 instance in 1 AZ, as default [**2**](<https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/asg.tf#:~:text=count%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%3D%20length(var.private_subnet_id)> "2") |
| Key for SSH connection | Generate yourselve and write public key to [SSH-key](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/SSH-key/ "SSH-key")                                                                              |
| Download packages      | [docker](https://www.docker.com/ "https://www.docker.com/")                                                                                                                                                     |
| Subnet                 | Create in [VPC](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/asg.tf#:~:text=vpc_zone_identifier%20%20%3D%20%5Bvar.private_subnet_id%5Bcount.index%5D%5D "VPC") module                              |
| Security Group         | Open [22, 80](https://github.com/OlesYudin/demo_2/blob/main/modules/ec2/asg.tf#:~:text=security_groups%20%3D%20%5Bvar.sg_app.id%2C%20var.sg_alb.id%5D "22, 80") ports                                           |
