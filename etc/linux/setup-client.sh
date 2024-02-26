#!/bin/bash

# Update packages
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker Engine
# @see https://docs.docker.com/engine/install/ubuntu/

## Uninstall conflicting old docker pakages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

## Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

## Add the repository to Apt sources:
echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt-get update

## Install latest version
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## Test docker
sudo docker run hello-world

## If "can't connect to docker daemon" appears even if 'sudo service docker start' was made
## @see https://github.com/docker/for-linux/issues/1406#issuecomment-1183487816
sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
sudo service docker start
sudo service docker status

## Create the docker group.
sudo groupadd docker

## Add your user to the docker group.
sudo usermod -aG docker $USER

## Log out and log back in so that your group membership is re-evaluated.
## If you're running Linux in a virtual machine, it may be necessary to restart the virtual machine for changes to take effect.
## You can also run the following command to activate the changes to groups:
## newgrp docker

## Verify that you can run docker commands without sudo.
docker run hello-world

# System config

## Add system required packages
sudo apt-get install -y software-properties-common zip unzip curl wget nano

## Add external repositories
sudo add-apt-repository -y ppa:ondrej/php && sudo add-apt-repository -y ppa:git-core/ppa && sudo apt-get update

## Install required apt packages for PHP
sudo apt-get install -y php8.1 php8.1-bcmath php8.1-common php8.1-curl php8.1-xml php8.1-gd php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-zip php8.1-imagick php8.1-mcrypt php8.1-ssh2 php8.1-fpm php8.1-cli php8.1-xdebug

## Install apt packages for GIT
sudo apt-get install -y git git-core bash-completion

## Install apt packages for Grunt
sudo apt-get install -y libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev libasound2 libxshmfence1 libglu1

## umask setup
(echo "umask 0002" | sudo tee -a /etc/profile) && (echo "umask 0002" | sudo tee -a /etc/bash.bashrc)

## Log out and log back in so that your umask is re-assigned
## You can also run the following command to activate the changes to groups:
## newgrp

# User config

## Install nvm
(curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash) && source ~/.bashrc

## Install node and npm
nvm install 18.15.0

## Install grunt and livereload
npm install -g grunt-cli && npm install -g livereload

## php config
sudo cp ./etc/php/conf.d/99-fpm.ini /etc/php/8.1/fpm/conf.d/
sudo cp ./etc/php/conf.d/99-cli.ini /etc/php/8.1/cli/conf.d/
#     && bash /root/conf/php/php-ini-conf.sh nginx \
#     # composer config
#     && bash /root/conf/composer/composer-install.sh \
#     # magento utilities
#     && chmod +x /root/conf/magento/* \
#     && mv /root/conf/magento/* /usr/local/bin/ \
#     # set git for magento user
#     && chown magento:magento /root/conf/git/.gitconfig \
#     && mv /root/conf/git/.gitconfig /home/magento/ \
#     # set oh-my-posh-theme for magento user
#     && chown magento:magento /root/conf/user/theme.omp.json \
#     && mv /root/conf/user/theme.omp.json /home/magento/ \
#     # set aliases for magento user
#     && chown magento:magento /root/conf/user/.bash_aliases \
#     && mv /root/conf/user/.bash_aliases /home/magento/ \
#     # remove conf folder
#     && rm -rf /root/conf
