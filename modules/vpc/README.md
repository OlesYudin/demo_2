# <div align="center">Create network</div>

### Variables:

- `env` - environment of project
- `cidr_vpc` - CIDR block for VPC
- `public_subnet` - CIDR-blocks for publick subnet
- `private_subnet` - CIDR-blocks for private subnet

### Structure of files:

- [`main.tf`](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/main.tf "main.tf`") - create VPC, Subnets (Private and Public), association with Subnets
- [`alb.tf`](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/alb.tf "alb.tf") - create Application Load Balancer to distribute traffic between EC2 instances
- [`asg.tf`](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/asg.tf "asg.tf") - create ASG, for EC2 instance configuration and correct NAT working
- [`variables.tf`](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/variables.tf "variables.tf") - variables for VPC module
- [`data.tf`](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/data.tf "data.tf") - dynamic search resources
- [`outputs.tf`](https://github.com/OlesYudin/demo_2/blob/main/modules/vpc/outputs.tf "outputs.tf") - outputs data for VPC module

### What we should to do:

1. `aws_vpc` - Create Virtual Private Cloud (VPC)
2. `aws_subnet` - Create subnets in VPC
3. `aws_internet_gateway` - Нужен для того, что бы в VPC был интернет
4. `aws_route_table` - Создает таблицу маршрутизации от VPC до Internet Gateway (IGW)
5. `aws_route_table_association` - Необходим для явного представления таблицы маршрутизации с подсетью
6. `aws_eip` - Нужен для создания Public IP, который будет присоединен к NAT
7. `aws_nat_gateway` - Создает NAT для VPC, который расположен в частной подсети, для работы EC2 instance в частной сети
8. `aws_lb` - Создает Load Balancer, в нашем случае создает Application Load Balancer (ALB)
9. `aws_lb_target_group` - Создает целевой ресурс (Target Group) для ALB. С помощью него будут созданы [_health check_](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/elb-healthchecks.html "health check")
10. `aws_lb_listener` - Слушатель (listener) для ALB, нужен для определения куда перенапрявлять трафик
11. `aws_lb_target_group_attachment` - Предоставляет возможность регистрировать EC2 instance и контейнеры в целевой группе ALB
12. `ASG`

### <div align="center">Networking scheme</div>

<p align="center">
  <img src="https://github.com/OlesYudin/demo_2/blob/main/images/Network%20infrastructure.png" alt="Scheme of Network in AWS"/>
</p>

### [1. Создание VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc "1. Создание VPC")

```
resource "aws_vpc" "vpc" {
  cidr_block       = var.cidr_vpc
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name  = "VPC"
  }
}
```

`cidr_block` - указываем какой будет адрес VPC. В моем случае, значение берется из переменной и получает вид _172.31.0.0/16_

`instance_tenancy` - аренда инстансов в VPC, указано _default_ что бы не платить за отдельный выделенный хост

`enable_dns_hostnames` - включения/отключения DNS-имен хостов в VPC

`enable_dns_support` - включиния/отключения поддержку DNS в VPC

### [2. Создание подсетей (Subnets)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet "2. Создание подсетей (Subnets)")

```
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr_vpc, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name              = "Subnet"
  }

  depends_on = [aws_vpc.vpc]
}
```

`count` - подсчет количества подсетей, что бы понимать сколько подсетей создавать. Количество считается из переменной _public_subnet_

`vpc_id` - в какой VPC будут создаваться подсети

`cidr_block` - какой CIDR будет иметь подсеть. В моем случае я использую функцию [cidrsubnet](https://www.terraform.io/language/functions/cidrsubnet "cidrsubnet") в которой берется значение из переменной _public_subnet_ добавляется префикс 8 (/16 --> /24), добавляется +1 к подсети (172.31.0.0 --> 172.31.1.0)

`availability_zone` - выбор зоны доступности, для того что бы созданная инфраструктура находилась в физически разных зонах (Повышение отказоустойчивости). Для этого, необходимо создать [data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones "data_source"), чтобы проверить какие есть доступные зоны в регионе. Далее присваиваем каждой подсети свою Availability Zone (AZ)

`map_public_ip_on_launch` - используется для публичных подсетей, что бы выдавать подсети внешний IP адресс

`depends_on` - указываем когда можно создавать подсеть. В моем случае, если VPC создано - начинает создаваться subnet

### [3. Создание Internet Gateway (IGW)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway "Создание Internet Gateway (IGW)")

Необходим для того, что бы в создзанной ранее VPC был интернет

```
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "IGW"
  }
}
```

`vpc_id` - указываем для какой VPC будет подключен IGW

### [4. Создание таблицы маршрутизации (Route Table)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table "Создание таблицы маршрутизации (Route Table)")

Необходим для маршрутизации трафик в созданной VPC

```
resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"                 # Allow all to IN/OUT traffic
    gateway_id = aws_internet_gateway.igw.id # Attach to IGW and Internet will work
  }

  depends_on = [aws_internet_gateway.igw]
}
```

`vpc_id` - указываем для какой VPC будет созданно правила маршрутизации

`route` - в данном блоке указывается список обьектов маршрута. Если оставить данный блок пустым - удаляться все управляемые маршруты для VPC

`cidr_block` - указывает на то, для кого будет доступна маршрутизация на вход и выход. В моем случае указанно разрешить всем трафик на вход и выход

`gateway_id` - Идентификатор интернет-шлюза VPC или виртуального частного шлюза. Указываем созданный IGW, что бы понимать откуда ходить в интернет

`depends_on` - пока не будет создан IGW, таблица маршрутизации не запустится

### [5. Создание связи между таблицей маршрутизации и подсетями (Route Table Association)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association "5. Создание связи между таблицей маршрутизации и подсетями (Route Table Association)")

Предоставляет ресурс для создания связи между таблицей маршрутов и подсетью или таблицей маршрутов и интернет-шлюзом или виртуальным частным шлюзом.

```
resource "aws_route_table_association" "publicrouteAssociation" {
  count          = length(var.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.publicroute.id

  depends_on = [aws_subnet.public_subnet, aws_route_table.publicroute]
}
```

`count` - подсчет количества подстей для которых будет создана связь

`subnet_id` - указания ID для создания ассоциации. В моем случае 2 подсети, по этому я использую _[count.index]_ для подсчета всех подсетей

`route_table_id` - указания из какой таблицы маршрутизации будет сделана связь между подсетью и таблицей маршрутизации (ассоциация)

`depends_on` - пока не будет создано подсети и таблицу маршрутизации, Route Table Association не будет создан

### [6. Создание EIP (Elastic IP)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip "6. Создание EIP (Elastic IP)")

Рерурс для создания Elastic IP (выделенный публичный IP адресс). Можно использовать для привязки к NAT, что бы частная сеть имела выход в Интернет.

```
resource "aws_eip" "nat_eip" {
  vpc = true

}
```

`vpc` - Для привязки EIP к VPC. _True_ - привязать к EIP

### [7. Создание NAT (Network Address Translation) Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway "7. Создание NAT (Network Address Translation) Gateway")

Рерурс для создания NAT, который будет использован для работы частный подсетей

```
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
}
```

`allocation_id` - Привязка NAT к id EIP к VPC

`subnet_id` - Указывает на то, в какой подсети будет создат NAT

### [8. Создание ALB (Application Load Balancer)](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb "8. Создание ALB (Application Load Balancer)")

Рерурс для создания балансировщика нагрузки (Load Balancer), который будет праспределять трафик под созданным EC2 instance.

Типы _Load Balancer_:

- Application (ALB). Работает на 7м уровне [модель OSI](https://en.wikipedia.org/wiki/OSI_model "модель OSI")
- Network (NLB)
- Elastic (ELB)

```
resource "aws_lb" "alb" {
  name                       = "ALB-${var.env}"
  internal                   = false
  load_balancer_type         = "application" # type of load balancer
  security_groups            = [var.sg_alb.id]
  subnets                    = aws_subnet.private_subnet.*.id
  ip_address_type            = "ipv4" # IP addres type (Can be IPv4 or dual)
  enable_deletion_protection = false
}
```

`name` - Название ALB

`internal` - Если false, ALB будет внешним

`load_balancer_type` - Указывает на то, како тип будет у LB. В нашем случае нужен _application_

`security_groups` - Присоединение Security Group к ALB. Для того, что бы открыть порты на ALB

`subnets` - Для каких сетей ALB будет совершать балансирование нагрузки

`ip_address_type` - Тип IP-адресов, используемых подсетями для балансировщика нагрузки. Возможные значения ipv4 (только для IPv4) и dualstack (Для IPv4 и IPv6)

`enable_deletion_protection` - Если задано значение true, удаление балансировщика нагрузки будет отключено через API AWS. Это предотвратит удаление балансировщика нагрузки Terraform. По умолчанию false.

### [9. Создание TG (Target Group) для ALB](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group "9. Создание TG (Target Group) для ALB")

Рерурс для создания целевой группы для ALB

```
resource "aws_lb_target_group" "alb_target" {
  name        = "TG-ALB-${var.env}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance" # If I switch on "IP" - not work, if "instance" - work. Change to IP and add

  # Health check for target group
  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
  }
}
```

`name` - Задание имени целевой группы

`port` - Порт, на который цели получают трафик, если только это не переопределено при регистрации конкретной цели. Требуется, когда target_type: instance или ip

`protocol` - Версия протокла для HTTP и HTTPS. По умолчанию используется HTTP1, который отправляет запросы к целям с использованием HTTP/1.1

`vpc_id` - Идентификатор VPC, в котором создается целевая группа. Требуется, когда target_type: instance или ip

`target_type` - Тип цели, который необходимо указать при регистрации целей в этой целевой группе

`health_check` - Блок для проверки рабостоспособности целевых ресурсов

`healthy_threshold` - Количество последовательных успешных проверок работоспособности, необходимых для того, чтобы считать нездоровую цель здоровой

`unhealthy_threshold` - Количество последовательных неудачных проверок работоспособности, необходимых для того, чтобы цель считалась неработоспособной. Для балансировщиков сетевой нагрузки это значение должно совпадать со значением _healthy_threshold_

`interval` - Приблизительное время в секундах между проверками (health check`ами) отдельной цели. Минимальное значение 5 секунд, максимальное значение 300 секунд

`protocol` - Протокол для подключения к цели. По умолчанию HTTP

`matcher ` - Коды ответов для использования при проверке работоспособных ответов от цели. Можно указать несколько значений (например, "200,202" для HTTP(s)) или диапазон значений (например, "200-299" или "0-99"). Требуется для HTTP/HTTPS/GRPC ALB. Применяется только к ALB (например, HTTP/HTTPS/GRPC), а не к NLB (например, TCP)

`timeout` - Количество времени в секундах, в течение которого отсутствие ответа означает неудачную проверку работоспособности. Для ALB диапазон составляет от 2 до 120 секунд, а значение по умолчанию — 5 секунд для _instance_ целевого типа

`path` - Место назначения для запроса проверки работоспособности (по какому пути на сайте будет произвиеден health check). Требуется для HTTP/HTTPS ALB и HTTP NLB. Применяется только к HTTP/HTTPS

### [10. Создание Слушателя (Listener) для ALB](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener "10. Создание Слушателя (Listener) для ALB")

Рерурс для создания слушателя (listener) ALB

```
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb_target.arn
    type             = "forward"
  }
}
```

`load_balancer_arn` - Обязательная привязка к ALB

`port` - Порт, который прослушивает балансировщик нагрузки

`protocol` - Протокол для подключения клиентов к балансировщику нагрузки. Для ALB допустимыми значениями являются _HTTP_ и _HTTPS_, по умолчанию — _HTTP_

`default_action` - Обязательный _блок конфигурации_ для действий по умолчанию

`target_group_arn` - ARN (Amazone Resource Name) целевой группы, в которую направляется трафик. Указывается, только если `type = forward` и нужно направить маршрут к одной целевой групп. Для маршрутизации к одной или нескольким целевым группам необходимо использовать `forward` вместо этого блока

`type` - Тип действия маршрутизации. Допустимые значения: _forward_, _redirect_, _fixed-response_ и _authenticate-cognito.authenticate-oidc_

### [11. Ассоциировать ALB Listener с EC2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment "11. Ассоциировать ALB Listener с EC2 instance")

Рерурс для создания ассоциации ALB listener с EC2 instance. Нужно использовать, если ALB работает по `type = "instance"`, а не `type = "ip"`

```
resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  count            = length(var.aws_instance.*.id)
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = var.aws_instance[count.index].id
  port             = var.app_port
}
```

`count` - Задание количество ассоциаций, которые будут созданы

`target_group_arn` - ARN целевой группы, с которой нужно ассоциировать цели (Target Group)

`target_id` - ID цели. Это id EC2 instance или id контейнера для ECS. Если целевой тип — ip, указать IP-адрес. Если целевой тип — alb, указать ARN к ALB

`port` - Порт, через который цели получают трафик
