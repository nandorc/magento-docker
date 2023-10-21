#!/bin/bash

# Start cron service
echo -e "\nINF~ Start cron service\n"
service cron start
service cron status

# Try to init magento app cron
if [ -d /magento-app/site ]; then
    cd /magento-app/site
    if [ -f bin/magento ]; then
        echo -e "\nINF~ Init app at /magento-app/site\n"
        bin/magento cron:install --force
        bin/magento cron:run
        bin/magento indexer:reindex
        bin/magento cache:flush
    fi
fi

# Start php-fpm service
echo -e "\nINF~ Start php-fpm service\n"
service php8.1-fpm start
service php8.1-fpm status

# Start nginx service
echo -e "\nINF~ Start nginx service\n"
service nginx start
service nginx status

# Attatch to nginx logs
echo -e "\nINF~ Attatch to nginx access logs\n"
tail -f /var/log/nginx/access.log
