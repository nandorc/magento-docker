# Magento Dockerizer

Project to deploy Magento Open Source locally using Docker Containers. Supported and installed components are:

- Adobe Commerce CE (Magento) v2.4.6
- Git v2.x
- Apache v2.4.x
- PHP v8.1.x
- Composer v2.x
- MySQL v8.0
- Elasticsearch : [v7.17.8](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/docker.html)
- Node v18.15.0 with NPM v9.5.0
- Grunt CLI

---

## 1. Installing new Magento App

---

### 1.1. Prepare services

Update configuration submodule

~~~bash
git submodule update --init
~~~

Start services

~~~bash
mage up -d --build
~~~

---

### 1.2. Create database

Open MySQL CLI using 'root' as password

~~~bash
mage mysql -p
~~~

Create database

~~~sql
create database magento_test;
~~~

Crear new user

~~~sql
create user 'magento'@'%' identified with mysql_native_password by 'magento';
~~~

Allow new user to use new database

~~~sql
grant all on magento_test.* to 'magento'@'%';
~~~

Flush privileges

~~~sql
flush privileges;
~~~

Close MySQL CLI

~~~sql
exit;
~~~

Test new user conection to MySQL using 'magento' as password

~~~bash
mage mysql -u magento -p
~~~

---

### 1.3. Get Adobe credentials

Go to [Magento Marketplace](https://marketplace.magento.com/) and create a pair of public/private keys for access to magento repo. ([Read more...](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/prerequisites/authentication-keys.html?lang=en))

---

### 1.4. Create new Magento project

Log in web container

~~~bash
mage bash
~~~

Create Magento v2.4.6 project using your Magento Marketplaces Access Keys

~~~bash
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.6 .
~~~

Update files/folders default permission and property

~~~bash
mageperms .
~~~

Install Magento App. Add any other needed params on install (see [documentation](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/advanced.html?lang=en))

~~~bash
bin/magento setup:install --base-url=http://localhost/ --db-host=db --db-name=magento_test --db-user=magento --db-password=magento --search-engine=elasticsearch7 --elasticsearch-host=search-engine --elasticsearch-port=9200 --use-rewrites=1 --cleanup-database
~~~

Ininitialize cron and indexer

~~~bash
mageinit
~~~

---

### 1.5. Test Access to Magento App

Access on you browser to [localhost](http://localhost) and you must see Magento App home page.

---

## 2. Using `mage` utility

---

On `bin` folder, `mage` utility can be found. It allows user to interact with **docker compose** services easily. Follow codeblock shows main commands related with `mage` utility

~~~bash
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
~~~

Any other command executed using `mage` command is done through `docker compose exec` command using `magento` user on `web` service, so if the command `mage ls -a /magento-app` is executed, a list of files and folders (`ls -a` command) located at `/magento-app` directory inside web container are shown

---

## 3. Manage ports for services deploy

---

Currently services forwards containers ports to specified values. If you need to use different ports, you can make a copy of `.env.sample` file and named to `.env` and modify ports

~~~bash
cp .env.sample .env
~~~
