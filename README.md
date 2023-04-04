# Magento Dockerizer

> **Version:** 1.4.3

Project to deploy Magento Open Source locally using Docker Containers. Supported and installed components are:

- Adobe Commerce CE (Magento) v2.4.6
- Git v2.x
- Apache v2.4.x
- PHP v8.1.x
- Composer v2.x
- MySQL v8.0
- Elasticsearch : [v7.17.8](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/docker.html)
- Node v18.15.0 with NPM v9.5.0

## Using `mage` utility

On `bin` folder, `mage` utility can be found. It allows user to interact with **docker compose** services easily. Follow codeblock shows main commands related with `mage` utility

```bash
#!/bin/bash

# Setup mage alias
bash ./bin/setup

# Start services
#   Additional args from docker compose up are received
mage up

# Dispose services
mage down

# Restart services
mage restart

# See currently running services
mage ps

# Log in to web-service terminal
mage bash

# Log in to mysql-service terminal
#   Parameters for mysql connection are received
mage mysql
```

Any other command executed using `mage` command is done through `docker compose exec` command using `magento` user on `web` service, so if the command `mage ls -a /magento-app` is executed, a list of files and folders (`ls -a` command) located at `/magento-app` directory inside web container are shown

## Installing new Magento App

### 0. Prepare services

---

```bash
#!/bin/bash

# Start services
mage up -d --build
```

### 1. Create database

---

```bash
#!/bin/bash

# Open MySQL CLI using 'root' as password
mage mysql -p
```

```sql
-- Create database
create database magento_test;

-- Crear new user
create user 'magento'@'%' identified with mysql_native_password by 'magento';

-- Allow new user to use new database
grant all on magento_test.* to 'magento'@'%';

-- Flush privileges and close MySQL CLI
flush privileges;
exit;
```

```bash
#!/bin/bash

# Test new user conection to MySQL using 'magento' as password
mage mysql -u magento -p
```

### 2. Get Adobe credentials

---

Go to [Magento Marketplace](https://marketplace.magento.com/) and create a pair of public/private keys for access to magento repo. ([Read more...](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/prerequisites/authentication-keys.html?lang=en))

### 3. Create new Magento project

---

```bash
#!/bin/bash

# Log in web container
mage bash

# Create Magento v2.4.6 project using your Magento Marketplaces Access Keys
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.6 .

# Update files/folders default permission and property
mageperms .

# Install Magento App
#   Add any other needed params on install (see documentation at https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/advanced.html?lang=en)
bin/magento setup:install --base-url=http://localhost/ --db-host=db --db-name=magento_test --db-user=magento --db-password=magento --search-engine=elasticsearch7 --elasticsearch-host=search-engine --elasticsearch-port=9200 --use-rewrites=1 --cleanup-database

# Install Magento Cron Tab
bin/magento cron:install --force
bin/magento cron:run
```

### 4. Test Access to Magento App

Access on you browser to [localhost](http://localhost) and you must see Magento App home page.
