#!/bin/bash

# Set ownership for .ssh folder
echo -e "\nINF~ Setup volumes\n"
cd /home/magento
sudo chown -v magento:magento .cache .config .local .ssh .vscode-server
sudo chmod -v 0700 /home/magento/.ssh

# Start cron service
echo -e "\nINF~ Start cron service\n"
sudo service cron start
sudo service cron status

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
sudo service php8.1-fpm start
sudo service php8.1-fpm status

# Start nginx service
echo -e "\nINF~ Start nginx service\n"
sudo service nginx start
sudo service nginx status

# Attatch to nginx logs
echo -e "\nINF~ Attatch to nginx access logs\n"
sudo tail -f /var/log/nginx/access.log
