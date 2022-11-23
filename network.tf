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

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow HTTP"
    from_port        = 80
    protocol         = "tcp"
    to_port          = 80
  }

  egress {
    description     = "Allow HTTP from instance"
    security_groups = [aws_security_group.instance.id]
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
  }

  tags = {
    "Name" = "${local.name_prefix}-lb-sg"
  }
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.main.id

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow SSH"
    from_port        = 22
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "tcp"
    to_port          = 22
  }

  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow All Egress"
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1"
    to_port          = 0
  }

  tags = {
    "Name" = "${local.name_prefix}-instance-sg"
  }
}

resource "aws_security_group_rule" "instance" {
  security_group_id        = aws_security_group.instance.id
  type                     = "ingress"
  description              = "Allow HTTP"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb.id

  depends_on = [
    aws_security_group.instance,
    aws_security_group.lb
  ]
}
