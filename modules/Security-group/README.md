# <div align="center">Creating dynamic Security Group</div>

## Table of open ports for APP (Policy of opened ports in [Security Group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group "Security Group"))

| Protocol                                                   | Port | IP-address                                                                                                                                                                                       |
| ---------------------------------------------------------- | ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [SSH](https://datatracker.ietf.org/doc/html/rfc4253 "SSH") | 22   | [Public IP](https://2ip.ru/ "Public IP") of my provider, created [VPC](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/variables.tf#:~:text=variable%20%22cidr_vpc%22%20%7B,%7D "VPC") |

## Table of open ports for ALB ([Application Load Balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb "Application Load Balancer"))

| Protocol                                                     | Port | IP-address                 |
| ------------------------------------------------------------ | ---- | -------------------------- |
| [HTTP](https://datatracker.ietf.org/doc/html/rfc2616 "HTTP") | 80   | Allow all IPv4 (0.0.0.0/0) |

```
resource "aws_security_group" "sg" {
  name        = "Security-group"
  description = "Security group description"
  vpc_id      = var.vpc_id.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
```

`name` - Название Security Group (SG)
`description` - Описание SG
`vpc_id` - присвоение к SG VPC

**Ingress** - block for _Inbound (Входящего)_ rules

**Egress** - block for _Outbound (Исходящего)_ rules

`from_port` - number of first port that will be open

`to_port` - number of last port that will be open

`protocol` - Type of protocol. "**-1**" means that connect to **all** port (in this case, _from_port_ and _to_port_ give value _0_)

`cidr_blocks` - list of CIDR-blocks that will allow to IPv4

`ipv6_cidr_blocks` - list of CIDR-blocks that will allow to IPv6

## Динамическое создание _ingress_ rules

```
  dynamic "ingress" {
    for_each = var.sg_port_cidr
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = "tcp"
      cidr_blocks = ingress.value
    }
  }
```

`for_each` - loop for ports

`content` - entry into the loop where the rules for the ports will be defined

`from_port`, `to_port`, `cidr_blocks` - called from a variable to determine open ports. In my case, the variable is used [кортеж (map) ключ-значение (key-value)](https://github.com/OlesYudin/demo_2/blob/main/modules/Security-group/variables.tf#:~:text=like%20key%20%2D%2D%3E%20value-,variable%20%22sg_port_cidr%22%20%7B,%7D,-%23%20Default%20inbound%20CIDR "кортеж (map) ключ-значение (key-value)"). In _key_ keep value of port, in _value_ keep value of CIDR-block
