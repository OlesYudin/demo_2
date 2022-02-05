# <div align="center">Creating EC2 instance</div>

Creating AWS EC2 instance in 2 private subnets and bastion host with [security group](https:// "security group").

## Description of EC2:

1. Bastion Host](https:// "Bastion Host") in [Public Subnet](https:// "Public Subnet")
2. 2 EC2 instance in Private Subnet that created by [ASG](https:// "ASG")

### <div align="center">Create keys for SSH connection</div>

<p align="center">
  <img src="https://" alt="Create keys for SSH connection"/>
</p>

## Connection to EC2 in Private Subnet:

1. Local. Generate 2 ssh-keys (1. key for bastion, 2. key for instance in private subnet) `ssh-keygen -t ed25519 -b 512 -f ~/.ssh/key_name -C 'Comment in public key'`
2. Input public keys to folder [SSH-key](https:// "SSH-key")
3. Do `terraform apply`
4. Connect to Bastion Host use your private key
5. Copy private key from local machine to Bastion Host
6. Connect to instance `ssh -i ~/.ssh/key_name ubuntu@private_ip` (As a default username: **ubuntu**)

## Settings of Bastion Host:

| Value                  | Default                                                                  |
| ---------------------- | ------------------------------------------------------------------------ |
| Region                 | [us-east-2b](https:// "us-east-2b")                                      |
| AMI                    | [Ubuntu 16.04 Server](https:// "Ubuntu 16.04 Server")                    |
| Instance type          | t2.micro                                                                 |
| Environment            | [Developer](https:// "Developer")                                        |
| Count                  | 1                                                                        |
| Key for SSH connection | Generate yourselve and write public key to [SSH-key](https:// "SSH-key") |
| Download packages      | [docker](https://www.docker.com/ "https://www.docker.com/")              |
| Subnet                 | Create in [VPC](https:// "VPC") module                                   |
| Security Group         | Open [22](https:// "22") ports                                           |

## Settings of instance in private subnets:

| Value                  | Default                                                         |
| ---------------------- | --------------------------------------------------------------- |
| Region                 | [us-east-2](https:// "us-east-2")                               |
| AMI                    | [Ubuntu 16.04 Server](https:// "Ubuntu 16.04 Server")           |
| Instance type          | t2.micro                                                        |
| Environment            | [Developer](https:// "Developer")                               |
| Count                  | 1 instance in 1 AZ, as default [**2**](https:// "2")            |
| Key for SSH connection | [your_privare_AWS_key.pem](https:// "your_privare_AWS_key.pem") |
| Download packages      | [docker](https://www.docker.com/ "https://www.docker.com/")     |
| Subnet                 | Create in [VPC](https:// "VPC") module                          |
| Security Group         | Open [22, 80](https:// "22, 80") ports                          |
