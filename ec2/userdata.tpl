#!/bin/bash
yum update -y
yum install httpd -y
echo "my terraform code" >> /var/www/html/index.html
service httpd start
chkconfig httpd on
