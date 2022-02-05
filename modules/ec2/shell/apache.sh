#!/bin/bash

sudo apt update && sudo apt -y upgrade
# Install docker
sudo apt install -y docker.io
# Execute container
sudo docker pull olesyudin/password-generator:latest
sudo docker run -d -p 80:80 --name=password-generator olesyudin/password-generator:latest

# sudo apt update && sudo apt -y upgrade
# sudo apt install -y apache2
# private_ip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
# echo "<h1 style='text-align: center; margin-top: 300px;'>Private IP of EC2: $private_ip</h1>" > /var/www/html/index.html
# sudo service apache2 start