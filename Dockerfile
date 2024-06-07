# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# System first update
ARG DEBIAN_FRONTEND=noninteractive

# System setup
RUN \
    # first update and upgrade
    apt-get update \
    && apt-get upgrade -y \
    # add system required packages
    && apt-get install -y software-properties-common zip unzip cron curl wget sudo nano \
    # add external repositories
    && add-apt-repository -y ppa:ondrej/php \
    && add-apt-repository -y ppa:git-core/ppa \
    && apt-get update \
    # install required apt packages
    && apt-get install -y \
    # - apt packages for nginx
    nginx \
    # - apt packages for mysql client
    mysql-client \
    # - apt packages for PHP
    php8.3 php8.3-bcmath php8.3-common php8.3-curl php8.3-xml php8.3-gd php8.3-intl php8.3-mbstring php8.3-mysql php8.3-soap php8.3-zip php8.3-imagick php8.3-mcrypt php8.3-ssh2 php8.3-fpm php8.3-cli php8.3-xdebug \
    # - apt packages for GIT
    git git-core bash-completion \
    # - apt packages for Grunt
    libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev libasound2 libxshmfence1 libglu1 \
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
    && npm install -g grunt-cli \
    # install livereload
    && npm install -g livereload \
    # install mage tools
    && git clone https://github.com/nandorc/magento-tools.git ~/.magetools
USER root
SHELL ["/bin/sh", "-c"]

# Copy config files
COPY ./etc/ /root/conf/

# App config
RUN \
    # entry point
    mv /root/conf/docker/init.sh / \
    && chmod +x /init.sh \
    # nginx config
    && mv /var/www/html /var/www/info \
    && chmod -v 0644 /root/conf/nginx/* \
    && chown -v root:root /root/conf/nginx/* \
    && rm -rf /etc/nginx/sites-enabled/default \
    && mv /root/conf/nginx/99-info /etc/nginx/sites-available/ \
    && ln -s /etc/nginx/sites-available/99-info /etc/nginx/sites-enabled \
    # php config
    && mv /root/conf/php/info/* /var/www/info/ \
    && cp /root/conf/php/conf.d/99-fpm.ini /etc/php/8.3/fpm/conf.d/ \
    && cp /root/conf/php/conf.d/99-cli.ini /etc/php/8.3/cli/conf.d/ \
    && bash /root/conf/php/php-ini-conf.sh nginx \
    # composer config
    && bash /root/conf/composer/composer-install.sh \
    # set git for magento user
    && chown magento:magento /root/conf/git/.bash_gitrc /root/conf/git/.gitconfig \
    && mv /root/conf/git/.bash_gitrc /home/magento/ \
    && mv /root/conf/git/.gitconfig /home/magento/ \
    # set aliases for magento user
    && chown magento:magento /root/conf/user/.bash_aliases \
    && mv /root/conf/user/.bash_aliases /home/magento/ \
    # remove conf folder
    && rm -rf /root/conf

# Container config
# MAGE_PORT: 80
# GRUNT_PORT: 8000
# LIVERELOAD_PORT: 35729
WORKDIR /magento-app
EXPOSE 80 8000 35729
ENTRYPOINT [ "/init.sh" ]
