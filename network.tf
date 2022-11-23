resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${local.name_prefix}-igw"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = length(var.subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.subnets, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    "Name" = "${local.name_prefix}-public-subnet-${count.index}"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    "Name" = "${local.name_prefix}-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "lb" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${local.name_prefix}-lb-sg"
  }
}

resource "aws_security_group_rule" "lb_allow_all_http_ingress" {
  security_group_id = aws_security_group.lb.id
  description       = "Allow HTTP"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "lb_allow_http_egress" {
  security_group_id = aws_security_group.lb.id
  description       = "Allow HTTP egress"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${local.name_prefix}-instance-sg"
  }
}

resource "aws_security_group_rule" "instance_allow_lb_http_ingress" {
  security_group_id        = aws_security_group.instance.id
  description              = "Allow HTTP"
  type                     = "ingress"
  source_security_group_id = aws_security_group.lb.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "instance_allow_all_egress" {
  security_group_id = aws_security_group.instance.id
  description       = "Allow All Egress"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}

resource "aws_security_group_rule" "instance_allow_all_ssh_ingress" {
  security_group_id = aws_security_group.instance.id
  description       = "Allow SSH"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}
