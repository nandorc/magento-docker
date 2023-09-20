# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# System first update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y && apt-get install -y software-properties-common

# System setup
RUN \
    # add apache apt external repositories
    add-apt-repository -y ppa:ondrej/apache2 \
    # add php apt external repository
    && add-apt-repository -y ppa:ondrej/php \
    # add git apt external repository
    && add-apt-repository -y ppa:git-core/ppa \
    # update apt packages list
    && apt-get update \
    # install required apt packages
    && apt-get install -y \
    # - apt packages for System
    zip unzip cron curl wget sudo nano \
    # - apt packages for Apache
    apache2 libapache2-mod-security2 \
    # - apt packages for mysql client
    mysql-client \
    # - apt packages for PHP
    php8.1 php8.1-bcmath php8.1-common php8.1-curl php8.1-xml php8.1-gd php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-zip php8.1-imagick php8.1-mcrypt php8.1-ssh2 php8.1-xdebug \
    # - apt packages for GIT
    git git-core bash-completion \
    # - apt packages for Grunt
    libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev libasound2 libxshmfence1 libglu1 \
    # enable apache modules
    && a2enmod deflate expires headers rewrite security2 ssl proxy_http \
    # umask setup
    && echo "umask 0002" >> /etc/profile \
    && echo "umask 0002" >> /etc/bash.bashrc \
    # oh-my-posh
    && (curl -s https://ohmyposh.dev/install.sh | bash -s) \
    # magento user setup
    && groupadd --gid 1000 magento \
    && useradd --uid 1000 --gid magento --create-home magento \
    && usermod --shell /bin/bash magento \
    && usermod -aG sudo magento \
    && passwd -d magento \
    && gpasswd -a magento www-data

# User config
USER magento
SHELL [ "/bin/bash", "-li", "-c" ]
RUN cd /home/magento \
    # confirm sudo user
    && touch .sudo_as_admin_successful \
    # install nvm
    && (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash) \
    && source .bashrc \
    # install node and npm
    && nvm install 18.15.0 \
    # install grunt
    && npm install -g grunt-cli \
    # install livereload
    && npm install -g livereload
USER root
SHELL ["/bin/sh", "-c"]

# Copy config files
COPY ./etc/ /root/conf/

# System config
RUN \
    # apache config
    mv /root/conf/apache/* /etc/apache2/sites-available/ \
    && mv /var/www/html /var/www/info \
    && a2ensite 001-search-engine-proxy.conf 002-info-vhost.conf \
    # php config
    && mv /root/conf/php/info/* /var/www/info/ \
    && mv /root/conf/php/conf.d/* /etc/php/8.1/apache2/conf.d/ \
    && bash /root/conf/php/php-ini-conf.sh apache \
    # composer config
    && bash /root/conf/composer/composer-install.sh \
    # magento utilities
    && chmod +x /root/conf/magento/* \
    && mv /root/conf/magento/* /usr/local/bin/ \
    # set git for magento user
    && chown magento:magento /root/conf/git/.gitconfig \
    && mv /root/conf/git/.gitconfig /home/magento/ \
    # set oh-my-posh-theme for magento user
    && chown magento:magento /root/conf/user/theme.omp.json \
    && mv /root/conf/user/theme.omp.json /home/magento/ \
    # set aliases for magento user
    && chown magento:magento /root/conf/user/.bash_aliases \
    && mv /root/conf/user/.bash_aliases /home/magento/ \
    # remove conf folder
    && rm -rf /root/conf

# Container config
WORKDIR /magento-app
EXPOSE 80 8080 8000
CMD [ "apachectl", "-D", "FOREGROUND" ]
