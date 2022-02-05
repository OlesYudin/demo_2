# <div align="center">Создание модульной инфраструктуры с помощью Terraform</div>

### Structure of modules:

1. [`ec2`](https:// "ec2")
   - [Bastion Host](https:// "Bastion Host") in public subnet of second AZ
   - [2 instance](https:// "2 instance") in private subnet in eache AZ
2. [`Security-group`](https:// "Security-group")
   - [sg_app](https:// "sg_app") open 22 port for SSH connection to instance
   - [sg_alb](https:// "sg_alb") open 80 port for HTTP to instance
3. [`vpc`](https:// "vpc")
   - [main.tf](https:// "main.tf") create VPC with 2 public and 2 private subnets
   - [alb.tf](https:// "alb.tf") create Application Load Balancer for instance in private subnets
   - [nat.tf](https:// "nat.tf") create 1 Network Address Translation in first public subnet to route outbound traffic from instance in private subnet to Internet

### <div align="center">Infrastructure scheme</div>

<p align="center">
  <img src="https://" alt="Scheme of creation VPC in AWS"/>
</p>
