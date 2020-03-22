#!/bin/bash

# install git
sudo apt update
sudo apt install -y git
sudo apt remove docker

# install latest version of docker the lazy way
curl -sSL https://get.docker.com | sh

# make it so you don't need to sudo to run docker commands
sudo usermod -aG docker ubuntu

# copy the dockerfile into /srv/docker
# if you change this, change the systemd service file to match
# WorkingDirectory=[whatever you have below]
sudo mkdir /srv/docker
sudo git clone https://github.com/autonomouse/darrenhoyland_info_stack.git /srv/docker

# install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# start up the application via docker-compose
docker-compose -f /srv/docker/docker-compose.yml up -d

# copy in systemd unit file and register it so our compose file runs
# on system restart
sudo cp /srv/docker/docker-compose-app.service /etc/systemd/system/docker-compose-app.service
sudo systemctl enable docker-compose-app
