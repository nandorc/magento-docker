#!/bin/bash

# Conectarse por ssh a la máquina ec2
#   ${env_host} - Host para la conexión SSH
#   ${env_port} - Puero para la conexión SSH
#   ${env_user} - Usuario de la conexión SSH
#   ${env_key} - Llave para acceder por SSH a la instancia
ssh -i "${env_key}" -p "${env_port}" "${env_user}@${env_host}"
# Cambiar a usuario root
sudo su
# Actualizar paquetes de sistema
apt-get update && apt-get upgrade -y
# Agregar repositorios externos para componentes
apt-get install -y software-properties-common && add-apt-repository -y ppa:ondrej/php && add-apt-repository -y ppa:git-core/ppa && apt-get update
# Instalar componentes
apt-get install -y zip unzip cron curl wget nano nginx mysql-client php8.1 php8.1-bcmath php8.1-common php8.1-curl php8.1-xml php8.1-gd php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-zip php8.1-imagick php8.1-mcrypt php8.1-ssh2 php8.1-fpm php8.1-cli git git-core bash-completion
# Asignar umask predeterminada a usuarios
echo "umask 0002" >>/etc/profile && echo "umask 0002" >>/etc/bash.bashrc
# Cambiar a usuario estandar
exit
# Agregar el usuario al grupo de usuarios de Nginx.
sudo gpasswd -a $USER www-data
# Clonar el repositorio de archivos de configuración para ambientes Magento
git clone https://github.com/nandorc/magento-scripts.git ~/.magento-scripts
# Ejecutar el archivo de configuración de PHP.
sudo bash ~/.magento-scripts/php/php-ini-conf.sh nginx
# Reiniciar servicio de php-fpm.
sudo service php8.1-fpm restart
# Instalar composer
sudo bash ~/.magento-scripts/composer/composer-install.sh
# Crear enlaces simbólicos de utilidades para Magento.
sudo ln -s ~/.magento-scripts/magento/mage* /usr/local/bin/
# Agregar estilos personalizados para la visualización de estados de GIT.
echo "[ -f ~/.magento-scripts/git/.bash_gitrc ] && source ~/.magento-scripts/git/.bash_gitrc" >>~/.bash_aliases
# Crear directoria principal para alojar la aplicación
sudo mkdir /magento-app && sudo chown $USER:$USER /magento-app && cd /magento-app
# Crear aplicación de Magento
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.6 site && cd site
# Actualizar permisos de archivos
mageperms .
# Ejecutar instalación de la aplicación
#   ${base_url} - Url base del sitio (con http y slash al final)
#   ${db_host} - Host para la conexión con base de datos (sin http)
#   ${db_name} - Nombre de la base de datos
#   ${db_user} - Usuario de la base de datos
#   ${db_pwd} - Contraseña de la base de datos
#   ${os_host} - Host de OpenSearch (con http y sin slash al final)
#   ${os_port} - Puerto de OpenSearch
#   ${os_user} - Usuario de OpenSearch
#   ${os_pwd} - Contraseña de OpenSearch
bin/magento setup:install --base-url="${base_url}" --backend-frontname="wsbo" --db-host="${db_host}" --db-name="${db_name}" --db-user="${db_user}" --db-password="${db_pwd}" --cleanup-database --search-engine="opensearch" --opensearch-host="${os_host}" --opensearch-port="${os_port}" --opensearch-enable-auth=1 --opensearch-username="${os_user}" --opensearch-password="${os_pwd}"
# Eliminar default vhost for nginx
sudo rm /etc/nginx/sites-enabled/default
# Copiar vhost de magento para nginx modificando propiedad y permisos
sudo cp ~/.magento-scripts/nginx/magento /etc/nginx/sites-available && sudo chmod 644 /etc/nginx/sites-available/magento && sudo chown root:root /etc/nginx/sites-available/magento
# Habilitar vhost para magento
sudo ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled/
# Reiniciar servicio nginx
sudo service nginx restart
