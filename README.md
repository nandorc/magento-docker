# Magento Dockerizer

> **Version:** 1.3.0

Project to deploy a Magento Open Source project locally using Docker Containers

## Getting started

```bash
#!/bin/bash

# Setup mage alias
bash ./bin/setup
```

## Devenlopment Environment Components Versions

- Adobe Commerce CE (Magento) v2.4.6
- Git v2.x
- Apache v2.4.x
- PHP v8.1.x
- Composer v2.x
- MySQL v8.0
- Elasticsearch : [v7.17.8](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/docker.html)
- Node v18.15.0 with NPM v9.5.0

## Using `mage` utility

```bash
#!/bin/bash

# Start services
#   Additional args from docker compose up are received
mage up

# Dispose services
mage down

# Restart services
mage restart

# Connect to web server terminal
mage bash

# Run composer command at magento-app directory
mage composer
```

Any command executed using `mage` command is done through `docker compose exec` command using `magento` user.

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

# Create Magento v2.4.5 project using your Magento Marketplaces Access Keys
mage composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.6 .

# Update files/folders default permission and property
mage perms

# Install Magento App
mage magento setup:install --base-url=http://localhost/ --db-host=db --db-name=magento_test --db-user=magento --db-password=magento --search-engine=elasticsearch7 --elasticsearch-host=search-engine --elasticsearch-port=9200 --use-rewrites=1 --cleanup-database

# Install Magento Cron Tab
mage magento cron:install --force
mage magento cron:run
```

### 4. Test Access to Magento App

Access on you browser to [localhost](http://localhost) and you must see Magento App home page.
