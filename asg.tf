data "aws_ami" "main" {

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2022-ami-2022*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "main" {
  key_name   = "${local.name_prefix}-key"
  public_key = file("${var.ssh_key_path}/${local.name_prefix}-key.pub")
}

resource "aws_launch_template" "main" {
  name                   = "${local.name_prefix}-launch-template"
  image_id               = data.aws_ami.main.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data              = filebase64("${path.module}/scripts/user_data.sh")
  tags = {
    "Name" = "${local.name_prefix}-launch-template"
  }
}

resource "aws_autoscaling_group" "main" {
  name                = "${local.name_prefix}-asg"
  vpc_zone_identifier = aws_subnet.public.*.id
  target_group_arns   = [aws_lb_target_group.main.arn]
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2

  launch_template {
    id = aws_launch_template.main.id
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "Project"
    value               = local.name_prefix
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
  }

  provisioner "local-exec" {
    command = "./scripts/get_instance_dns.sh"
  }
}
