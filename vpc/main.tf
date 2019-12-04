provider "aws" {
  region = "us-west-2"
}

data "aws_availability_zones" "avz" {}

#Vpc creation
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "my_terraform_vpc"
  }
}

#Internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_terraform_igw"
  }
}

#Public Route table
resource "aws_route_table" "Public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "Public_route_table"
  }
}

#Private route table
//noinspection MissingProperty
resource "aws_default_route_table" "Private_route_table" {
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id
  tags = {
    Name = "Private_route_table"
  }
}

#Public subnet
resource "aws_subnet" "public_subnet" {
  count = 2
  cidr_block = var.public_cidrs[count.index]
  vpc_id = aws_vpc.my_vpc.id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.avz.names[count.index]
  tags  = {
    Name = "Public_subnet.${count.index+1}"
  }
}

#private subnet

resource "aws_subnet" "private_subnet" {
  count = 2
  cidr_block = var.private_cidrs[count.index]
  vpc_id = aws_vpc.my_vpc.id
   availability_zone = data.aws_availability_zones.avz.names[count.index]
  tags = {
    Name = "Private_subnet.${count.index+1}"
  }

}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_subnet_assoc" {
  count = 2
  route_table_id = aws_route_table.Public_route_table.id
  subnet_id = aws_subnet.public_subnet.*.id[count.index]
  depends_on = [aws_route_table.Public_route_table , aws_subnet.public_subnet]
}

#Associate private subnet with private route table
resource "aws_route_table_association" "private_subnet_assoc" {
  count = 2
  route_table_id = aws_default_route_table.Private_route_table.id
  subnet_id = aws_subnet.private_subnet.*.id[count.index]
  depends_on = [aws_default_route_table.Private_route_table,aws_subnet.private_subnet]
}

#security group creation
resource "aws_security_group" "sg" {
  name = "test_sg"
  vpc_id = aws_vpc.my_vpc.id
}

#Ingress security group
resource "aws_security_group_rule" "ssh_inbound" {
  from_port = 22
  protocol = "tcp"
  security_group_id = aws_security_group.sg.id
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_allow" {
  from_port = 80
  protocol = "tcp"
  security_group_id = aws_security_group.sg.id
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

#Allo all outbound
resource "aws_security_group_rule" "allow_outbound" {
  from_port = 0
  protocol = "-1"
  security_group_id = aws_security_group.sg.id
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

