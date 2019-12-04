provider "aws" {
  region = "us-west-2"
}
data "aws_availability_zones" "avz" {}

#Getting latest cento os AMI id. To know how to get owner id see the 100days devops documentaion
data "aws_ami" "my_centos" {
  owners = [679593333241]
  most_recent = true
  filter {
    name = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}

#Creating key pair
resource "aws_key_pair" "My_keypair" {
  key_name = "Terraform_keypair"
  public_key = "${file(var.my_public_key)}"
  /*public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdqg1ajFNpBwoTct4CYFF9/d/i9hLTOowtUH6Cxd+nzmQLgE+1x0m3KdR0O4uSS/k63lJg5MYMbXeQGXxm2ivoZhnjIe5W0RjXLTC+3dDSrmnbodhXdmQ2C0j7Jr/mHVhB0JKzhfZrLzfOKeAGdVULH4gjWLK1D1ryPBCoF4b837ky2mxLBZAQY5YO+AD6Qu12DAfamq6gC0ZAYB6Nuq+itGrnwutPmivUttZIz9WxjrmtlX17yyzkHEb+TXP1gPbZedU1QsTkFkSIIh9qPg9sOUuPW3b6bpD4qixLF6SCvGhnbVunlb+0cPC6aR3gxDBY1FA0txgZiwCPQNESPrun redmorph@redmorph-Inspiron-5558o"*/
}
#Defining user data file
data "template_file" "init" {
  template = file("${path.module}/userdata.tpl")
}

#creating Instance
resource "aws_instance" "web" {
  count = 2
  ami = data.aws_ami.my_centos.id
  instance_type = var.instance_type
  key_name = aws_key_pair.My_keypair.id
  vpc_security_group_ids = ["${var.security_group}"]
  subnet_id = element(var.subnets,count.index )
  user_data = data.template_file.init.rendered

  tags = {

    Name = "my-instance-${count.index + 1}"
  }
}
# Creating Volumes
resource "aws_ebs_volume" "volume" {
  count = 2
  availability_zone = data.aws_availability_zones.avz.names[count.index]
  size = 1
  type = "gp2"
}

#Attaching volumes to isnatnces
#Type is gp2(other available options "standard", "gp2", "io1", "sc1" or "st1" (Default: "standard"))
resource "aws_volume_attachment" "my-vol-attach" {
  count = 2
  device_name = "/dev/xvdh"
  instance_id = aws_instance.web.*.id[count.index]
  volume_id = aws_ebs_volume.volume.*.id[count.index]
}

