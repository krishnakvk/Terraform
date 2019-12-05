resource "aws_launch_configuration" "my-test-launch-config" {
  image_id = "ami-003d8924a33dc0fd7"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.my-asg-sg.id]
  key_name = "Terraform_keypair"


  user_data = <<-EOF
      #!/bin/bash
      yum update -y
      yum install httpd -y
      echo "My autoscaling instance" > /var/www/html/index.html
      service httpd start
      chkconfig httpd on
      EOF
lifecycle {
  create_before_destroy = true
}
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.my-test-launch-config.name
  vpc_zone_identifier = [var.subnet1,var.subnet2]
  target_group_arns = [var.target_group_arn]
  health_check_type = "ELB"
  max_size = 2
  min_size = 2

  tag {
    key = "name"
    value = "my-test-sg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "my-asg-sg" {
  name = "my-asg-sg"
  vpc_id = var.vpc_id
}
resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.my-asg-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
