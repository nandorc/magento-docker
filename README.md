# Magento Dockerizer

Project to deploy Magento Open Source locally using Docker Containers. Supported and installed components in default config:

- Adobe Commerce CE (Magento) v2.4.6
- Git v2.x
- Nginx
- PHP v8.1.x
- Composer v2.x
- MySQL v8.0
- Opensearch v2.x
- Node v18.15.0 with NPM v9.5.0
- Grunt CLI

---

## 1. Installing new Magento App

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
create database magento_default;
~~~

Create new user

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

Create a new file to store variables for new env.

> In order to setup a fresh Magento env you could consider next variables:
>
> - `git_protocol`, `git_user`, `git_key`, `git_route` and `git_branch` could be left empty or with its default value.
> - `repo_user` is the name that you are going to use when commiting changes to git. You must put it between quotes ("").
> - `repo_email` is the email that you are going to use when commiting changes to git.
> - `db_host` is `db` because is the in network recognized name given for database service
> - `db_name` is the name of the database which is going to be connected to Magento app, in case of following instructions in step 1.2 it is `magento_default`
> - `db_user` is the user to connect to database, in case of following instructions in step 1.2 is `magento`
> - `db_pwd` is the password to connect to database, in case of following instructions in step 1.2 is `magento`
> - `search_engine` is the selected search engine to use, in case of this containerized service it must be `opensearch`
> - `search_host` is the network recognized name for Opensearch service, it's value must be `http://search-engine`
> - `search_port` is the port used by Opensearch, it value must be `9200`
> - `search_auth`, `search_user` and `search_pwd` must be left empty.
> - `base_url` is the URl to serve the Magento app, it could be `http://localhost/`
> - `admin_path` is the path that will be used to access to Magento Back Office. It could be `admin`
> - `magento_version` is the specific Magento version to use when installing a fresh new application. Default is `2.4.6`
> - `php_version` is the specific specify PHP version to use when generating Nginx host file. Default is `8.1`
> - `excluded_on_install` could be left empty

~~~bash
mage env:vars-create default
~~~

Execute command to setup a new env with the stored variables

~~~bash
mage env:setup --name default --no-repo
~~~

Switch to new created env

~~~bash
env-move -s default
~~~

Execute first deliver

~~~bash
mage deliver
~~~

> Inside web container the `mage` command used to setup the new env comes from a public repo for [Magento Tools](https://github.com/nandorc/magento-tools). You could type the command `mage list` inside the container to know more about the tools you can use.

---

### 1.5. Test Access to Magento App

Access on you browser to [localhost](http://localhost) and you must see Magento App home page.

---

## 2. Use a different PHP version

If you want to use a different PHP version, you could create a `.env` file and define a variable named `PHP_VERSION` where you set the PHP version you want the container to use. You can copy the content in the `.env.sample` file where it's defined the PHP_VERSION variable.

---

## 3. Using `mage` utility

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
