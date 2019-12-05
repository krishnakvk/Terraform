/*provider "aws" {
  region = "us-west-2"
}*/

# Target group ceration
resource "aws_alb_target_group" "my-target-group" {
  health_check {
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 5
  }
  name = "my-test-tg"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id = var.vpc_id
}

# Application load balancer creation
resource "aws_alb" "my-aws-alb" {
  name = "my-test-alb"
  internal = false
  security_groups = [aws_security_group.my-alb-sg.id]
  subnets = [var.subnet1,var.subnet2]
  tags = {
    Name = "my-tets-alb"
  }
  ip_address_type = "ipv4"
  load_balancer_type = "application"
}

#listener defination
resource "aws_alb_listener" "my-test-alb-listner" {
  load_balancer_arn = aws_alb.my-aws-alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.my-target-group.arn
  }
}
# Security group creation for alb
resource "aws_security_group" "my-alb-sg" {
  name = "my-alb-sg"
  vpc_id = var.vpc_id
}
# SSH Inbound rule
resource "aws_security_group_rule" "inbound_ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

#HTTP inbound rule
resource "aws_security_group_rule" "inbound_http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

#Allow all ports in outbound
resource "aws_security_group_rule" "outbound_all" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.my-alb-sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}