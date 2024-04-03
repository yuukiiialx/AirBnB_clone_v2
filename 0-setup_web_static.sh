#!/usr/bin/env bash
# Prepare your web servers

# install nginx
sudo apt-get update -y
sudo apt-get install nginx -y

# create folders
sudo mkdir -p /data/web_static/releases/test/
sudo mkdir -p /data/web_static/shared/
sudo sh -c 'echo "this is Mohamed"> /data/web_static/releases/test/index.html'
# create symbolic link
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current

sudo chown -R ubuntu:ubuntu /data/

# Update the Nginx configuration to serve the content
sudo sh -c 'echo "server {
    listen 80;
    listen [::]:80 default_server;
    server_name mohamed;
    location /hbnb_static {
        alias /data/web_static/current/;
    }
}" > /etc/nginx/sites-available/default'

# restart nginx
sudo service nginx restart
