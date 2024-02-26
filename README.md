# Magento Dockerizer

Project to deploy Magento Open Source locally using Docker Containers. Supported and installed components are:

- Adobe Commerce CE (Magento) v2.4.6
- Git v2.x
- Nginx
- PHP v8.1.x
- Composer v2.x
- MySQL v8.0
- Elasticsearch : [v7.17.8](https://www.elastic.co/guide/en/elasticsearch/reference/7.17/docker.html)
- Node v18.15.0 with NPM v9.5.0
- Grunt CLI

---

## 1. [TODO] Installing new Magento App

---

### 1.1. Prepare services

Start services

~~~bash
bin/mage up -d --build
~~~

---

### 1.2. Create database

Open MySQL CLI using 'root' as password

~~~bash
bin/mage mysql -p
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
bin/mage mysql -u magento -p
~~~

---

### 1.3. Get Adobe credentials

Go to [Magento Marketplace](https://marketplace.magento.com/) and create a pair of public/private keys for access to magento repo. ([Read more...](https://experienceleague.adobe.com/docs/commerce-operations/installation-guide/prerequisites/authentication-keys.html?lang=en))

---

### 1.4. Create new Magento project

Log in web container

~~~bash
bin/mage bash
~~~

Create folder to store new project

~~~bash
mkdir -v -p /magento-app/test/site && cd /magento-app/test/site
~~~

Create Magento v2.4.6 project using your Magento Marketplaces Access Keys

~~~bash
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.5 .
~~~

Init git repository for project and make first commit

~~~bash
git init && git add . && git commit -m "Create Magento v2.4.5 project"
~~~

Create copy of enviroment variables file

~~~bash
cp ~/vars.sh.sample /magento-app/vars-test.sh
~~~

Open and edit vars (using for example `nano /magento-app/vars-test.sh`) file to set this values (all other values could stay blank):

~~~bash
db_host=db
db_name=magento_test
db_user=magento
db_pwd=magento
search_engine=elasticsearch7
search_host=http://search-engine
search_port=9200
base_url=http://localhost/
~~~

[TODO] Execute env-setup command

~~~bash
env-setup --name test --mode dev --vars /magento-app/vars-test.sh
~~~

[TODO] Execute first deliver

~~~bash
mage deliver
~~~

Activate environment

~~~bash
env-switch test
~~~

---

### 1.5. Test Access to Magento App

Access on you browser to [localhost](http://localhost) and you must see Magento App home page.

---

## 2. Using `mage` utility

---

On `bin` folder, `mage` utility can be found. It allows user to interact with **docker compose** services easily. Following codeblock shows main commands related with `mage` utility

~~~bash
#!/bin/bash

# Setup mage alias (Tested on WSL Ubuntu and Git Bash)
bash ./bin/setup

# Log in to web-service terminal as magento user
mage bash

# Log in to mysql-service terminal
#   Parameters for mysql connection are received
mage mysql
~~~

Any other command executed using `mage` command is done through `docker compose` command, so if the command `mage up -d --build` is executed, is the same than typing `docker compose up -d --build` command.
