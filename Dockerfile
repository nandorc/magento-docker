# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# System config
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y software-properties-common zip unzip cron curl wget

# User config
RUN echo "umask 0002" >> /etc/profile \
  && echo "umask 0002" >> /etc/bash.bashrc \
  && groupadd --gid 1000 magento \
  && useradd --uid 1000 --gid magento --create-home magento \
  && touch /home/magento/.bash_aliases \
  && chown magento:magento /home/magento/.bash_aliases

# Apache config
COPY ./etc/apache/* /home/magento/
RUN add-apt-repository -y ppa:ondrej/apache2 \
  && apt-get update \
  && apt-get install -y apache2 libapache2-mod-security2 \
  && a2enmod deflate expires headers rewrite security2 ssl proxy_http \
  && gpasswd -a magento www-data \
  && mv /home/magento/*.conf /etc/apache2/sites-available/ \
  && a2ensite info-vhost.conf search-engine-proxy.conf \
  && mv /var/www/html /var/www/info

# PHP config
COPY ./etc/php/* /home/magento/
RUN add-apt-repository -y ppa:ondrej/php \
  && apt-get update \
  && apt-get install -y php8.1 php8.1-bcmath php8.1-common php8.1-curl php8.1-xml php8.1-gd php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-zip php8.1-imagick php8.1-mcrypt php8.1-ssh2 \
  && bash /home/magento/php-ini-conf.sh \
  && rm -fv /home/magento/php-ini-conf.sh \
  && mv /home/magento/phpinfo.php /var/www/info/

# Composer config
COPY ./etc/composer/* /home/magento/
RUN bash /home/magento/composer-install.sh \
  && rm -fv /home/magento/composer-install.sh

# Git config
COPY --chown=magento:magento --chmod=644 ./etc/git/* /home/magento/
RUN add-apt-repository -y ppa:git-core/ppa \
  && apt-get update \
  && apt-get install -y git \
  && echo '[ -f ~/git-style.sh ] && source ~/git-style.sh' >>/home/magento/.bash_aliases

# Node and NPM
USER magento
SHELL ["/bin/bash", "--login", "-i", "-c"]
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
RUN source /home/magento/.bashrc \
  && nvm install 18.15.0
SHELL ["/bin/bash", "--login", "-c"]

# Container config
USER root
WORKDIR /magento-app
EXPOSE 80 8080
CMD [ "apachectl", "-D", "FOREGROUND" ]
