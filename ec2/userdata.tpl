#!/bin/bash
mkfs.ext4 /dev/xvdh
mount /dev/xvdh /mnt
echo /dev/xvdh /mnt defaults,nofail 0 2 >> /etc/fstab

yum update -y
yum install httpd -y
echo "my terraform code" >> /var/www/html/index.html
service httpd start
chkconfig httpd on
