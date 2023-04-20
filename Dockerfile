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
  zip unzip cron curl wget sudo \
  # - apt packages for Apache
  apache2 libapache2-mod-security2 \
  # - apt packages for PHP
  php8.1 php8.1-bcmath php8.1-common php8.1-curl php8.1-xml php8.1-gd php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-zip php8.1-imagick php8.1-mcrypt php8.1-ssh2 \
  # - apt packages for GIT
  git git-core bash-completion \
  # - apt packages for Grunt
  libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev libasound2 libxshmfence1 libglu1 \
  # enable apache modules
  && a2enmod deflate expires headers rewrite security2 ssl proxy_http \
  # umask setup
  && echo "umask 0002" >> /etc/profile \
  && echo "umask 0002" >> /etc/bash.bashrc \
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
  && npm install -g grunt-cli
USER root
SHELL ["/bin/sh", "-c"]

# Copy config files
COPY ./etc/ /root/

# System config
RUN \
  # apache config
  mv /root/apache/* /etc/apache2/sites-available/ \
  && mv /var/www/html /var/www/info \
  && a2ensite info-vhost.conf search-engine-proxy.conf \
  && rm -rf /root/apache \
  # php config
  && mv /root/php/phpinfo.php /var/www/info/ \
  && bash /root/php/php-ini-conf.sh \
  && rm -rf /root/php \
  # composer config
  && bash /root/composer/composer-install.sh \
  && rm -rf /root/composer \
  # magento utilities
  && chmod +x /root/magento/* \
  && mv /root/magento/* /usr/local/bin/ \
  && rm -rf /root/magento \
  # set git for magento user
  && chown magento:magento /root/git/.bash_gitrc /root/git/.gitconfig \
  && mv /root/git/.bash_gitrc /home/magento/ \
  && mv /root/git/.gitconfig /home/magento/ \
  && rm -rf /root/git \
  # set aliases for magento user
  && chown magento:magento /root/user/.bash_aliases \
  && mv /root/user/.bash_aliases /home/magento/ \
  && rm -rf /root/user

# Container config
WORKDIR /magento-app
EXPOSE 80 8080 8000
CMD [ "apachectl", "-D", "FOREGROUND" ]
