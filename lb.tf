
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.lb.id]
  subnets            = aws_subnet.public.*.id

  tags = {
    "Name" = "${local.name_prefix}-alb"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${local.name_prefix}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  tags = {
    "Name" = "${local.name_prefix}-target-group"
  }
}
