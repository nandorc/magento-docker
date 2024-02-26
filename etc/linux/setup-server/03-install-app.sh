#!/bin/bash

# Conectarse por ssh a la máquina ec2
#   ${env_host} - Host para la conexión SSH
#   ${env_port} - Puero para la conexión SSH
#   ${env_user} - Usuario de la conexión SSH
#   ${env_key} - Llave para acceder por SSH a la instancia
ssh -i "${env_key}" -p "${env_port}" "${env_user}@${env_host}"
# Crear directoria principal para alojar la aplicación
sudo mkdir /magento-app && sudo chown $USER:$USER /magento-app
# Preparar directorio para build con el repositorio de la aplicación y la rama build
#   ${repo_path} - Path donde se encuentra el repositorio (sin https)
#   ${repo_user} - Usuario para acceso
#   ${repo_pwd} - Contraseña de acceso
#   ${env_branch} - Rama principal del ambiente
git clone -b "${repo_branch}" "https://${repo_user}:${repo_pwd}@${repo_path}" /magento-app/build && cd /magento-app/build && git switch -c build
# Actualizar dependencias
composer i && git restore .
# Deshabilitar parcialmente módulo de SMTP de Mageplaza
bin/magento module:disable -c Mageplaza_Smtp
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
# Habilitar módulo de SMTP de Mageplaza
bin/magento module:enable -c Mageplaza_Smtp
# Compilar dependencias y desplegar estáticos
bin/magento setup:di:compile && bin/magento setup:static-content:deploy -f
# Remplazar temporalmente .gitignore para subir cambios a la zona de stage
cp .gitignore-build .gitignore && git add . && git restore --staged .gitignore && git restore .gitignore
# Verificar y guardar cambios en la rama build
[ -n "$(git status -s)" ] && git commit -m "Build app at $(date)"
# Preparar directorio para site con el repositorio local
git clone -b build /magento-app/build/.git /magento-app/site && cd /magento-app/site
# Copiar archivo de variables de entorno
cp /magento-app/build/app/etc/env.php /magento-app/site/app/etc/
# Ajustar permisos y configurar modo de producción en directorio de site
mageperms . && bin/magento deploy:mode:set -s production && git restore .
# Actualizar configuración
bin/magento app:config:import && bin/magento setup:upgrade --keep-generated
# Instalar cron
bin/magento cron:install --force && bin/magento cron:run
# Reindexar y limpiar cache
bin/magento indexer:reindex && bin/magento cache:flush
# Eliminar default vhost for nginx
sudo rm /etc/nginx/sites-enabled/default
# Copiar vhost de magento para nginx modificando propiedad y permisos
sudo cp ~/.magento-scripts/nginx/magento /etc/nginx/sites-available && sudo chmod 644 /etc/nginx/sites-available/magento && sudo chown root:root /etc/nginx/sites-available/magento
# Habilitar vhost para magento
sudo ln -s /etc/nginx/sites-available/magento /etc/nginx/sites-enabled/
# Reiniciar servicio nginx
sudo service nginx restart
