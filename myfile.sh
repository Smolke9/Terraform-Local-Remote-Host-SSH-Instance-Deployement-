#!/bin/bash
sudo apt update
sudo apt install nginx -y
sudo service nginx start
cd /var/www/html
sudo rm *.html
sudo echo "hello from local and remote terraform" > index.html
