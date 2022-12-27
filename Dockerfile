# syntax=docker/dockerfile:1
FROM ubuntu:22.04

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y software-properties-common zip unzip

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
  && add-apt-repository -y ppa:ondrej/php \
  && apt-add-repository -y ppa:ondrej/apache2 \
  && apt-get -y update \
  && apt-get install -y apache2 libapache2-mod-security2 php8.1 php8.1-bcmath php8.1-common php8.1-curl php8.1-xml php8.1-gd php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-zip php8.1-imagick php8.1-mcrypt php8.1-ssh2 \
  && a2enmod deflate expires headers rewrite security2 ssl proxy_http

COPY ./etc/apache/* /etc/apache2/sites-available/
COPY ./etc/php/* /var/www/

RUN a2ensite site-vhost.conf search-engine-proxy.conf \
  && chmod +x /var/www/php-ini-conf.sh \
  && bash /var/www/php-ini-conf.sh \
  && rm -fv /var/www/php-ini-conf.sh \
  && mv /var/www/phpinfo.php /var/www/html/ \
  && bash /var/www/composer-install.sh \
  && rm -fv /var/www/composer-install.sh

RUN echo "umask 0002" >> /etc/profile \
  && echo "umask 0002" >> /etc/bash.bashrc \
  && groupadd --gid 1000 magento \
  && useradd --uid 1000 --gid magento --create-home magento \
  && gpasswd -a magento www-data

WORKDIR /magento-app

EXPOSE 80 8080

CMD [ "apachectl", "-D", "FOREGROUND" ]
