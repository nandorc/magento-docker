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
