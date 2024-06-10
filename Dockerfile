# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Container variables
ARG DEBIAN_FRONTEND=noninteractive
ARG PHP_VERSION=8.1

# System general setup
RUN \
    # first update and upgrade
    apt-get update && apt-get upgrade -y \
    # add system required packages
    && apt-get install -y software-properties-common zip unzip cron curl wget sudo nano \
    # add external repositories
    && add-apt-repository -y ppa:ondrej/php && add-apt-repository -y ppa:git-core/ppa && apt-get update

# System users setup
RUN \
    # umask setup
    echo "umask 0002" >> /etc/profile && echo "umask 0002" >> /etc/bash.bashrc \
    # magento user creation
    && groupadd --gid 1000 magento && useradd --uid 1000 --gid magento --create-home magento \
    # magento user config
    && usermod --shell /bin/bash magento && usermod -aG sudo magento && passwd -d magento

# Global apt dependencies setup
RUN \
    # install required apt packages (git, nginx and mysql-client)
    apt-get install -y git git-core bash-completion nginx mysql-client \
    # add magento user to www-data group
    && gpasswd -a magento www-data

# DEV container only required packages for Grunt
RUN apt-get install -y libgconf-2-4 libatk1.0-0 libatk-bridge2.0-0 libgdk-pixbuf2.0-0 libgtk-3-0 libgbm-dev libnss3-dev libxss-dev libasound2 libxshmfence1 libglu1

# User config
USER magento
SHELL [ "/bin/bash", "-li", "-c" ]
RUN cd /home/magento \
    # confirm sudo user
    && touch .sudo_as_admin_successful \
    # install nvm
    && (curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash) && source .bashrc \
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

# PHP apt packages
RUN apt-get install -y php${PHP_VERSION} php${PHP_VERSION}-bcmath php${PHP_VERSION}-common php${PHP_VERSION}-curl php${PHP_VERSION}-xml php${PHP_VERSION}-gd php${PHP_VERSION}-intl php${PHP_VERSION}-mbstring php${PHP_VERSION}-mysql php${PHP_VERSION}-soap php${PHP_VERSION}-zip php${PHP_VERSION}-imagick php${PHP_VERSION}-mcrypt php${PHP_VERSION}-ssh2 php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-xdebug

# Copy config files
COPY ./etc/ /root/conf/

# App config
RUN \
    # entry point
    mv -v /root/conf/docker/init.sh / \
    && chmod -v +x /init.sh \
    # nginx config
    && mv -v /var/www/html /var/www/info \
    && chmod -v 0644 /root/conf/nginx/* \
    && chown -v root:root /root/conf/nginx/* \
    && rm -rfv /etc/nginx/sites-enabled/default \
    && sed -i -e "s/%PHP_VERSION%/${PHP_VERSION}/" /root/conf/nginx/99-info \
    && mv -v /root/conf/nginx/99-info /etc/nginx/sites-available/ \
    && ln -v -s /etc/nginx/sites-available/99-info /etc/nginx/sites-enabled \
    # php config
    && mv -v /root/conf/php/info/* /var/www/info/ \
    && cp -v /root/conf/php/conf.d/99-fpm.ini /etc/php/${PHP_VERSION}/fpm/conf.d/ \
    && cp -v /root/conf/php/conf.d/99-cli.ini /etc/php/${PHP_VERSION}/cli/conf.d/ \
    && bash /root/conf/php/php-ini-conf.sh --webserver nginx --php-version ${PHP_VERSION} \
    # composer config
    && bash /root/conf/composer/composer-install.sh \
    # set git for magento user
    && chown -v magento:magento /root/conf/git/.bash_gitrc /root/conf/git/.gitconfig \
    && mv -v /root/conf/git/.bash_gitrc /home/magento/ \
    && mv -v /root/conf/git/.gitconfig /home/magento/ \
    # set aliases for magento user
    && chown -v magento:magento /root/conf/user/.bash_aliases \
    && mv -v /root/conf/user/.bash_aliases /home/magento/ \
    # remove conf folder
    && rm -rfv /root/conf

# Container config
# MAGE_PORT: 80
# GRUNT_PORT: 8000
# LIVERELOAD_PORT: 35729
WORKDIR /magento-app
EXPOSE 80 8000 35729
ENTRYPOINT [ "/init.sh" ]
