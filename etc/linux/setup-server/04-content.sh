#!/bin/bash

# Conectarse por ssh a la máquina ec2
#   ${env_host} - Host para la conexión SSH
#   ${env_port} - Puero para la conexión SSH
#   ${env_user} - Usuario de la conexión SSH
#   ${env_key} - Llave para acceder por SSH a la instancia
ssh -i "${env_key}" -p "${env_port}" "${env_user}@${env_host}"
# Ingresar al directorio del site
cd /magento-app/site
# Crear usuario administrador principal
#   ${admin_user} - Usuario para inicio de sesión
#   ${admin_pwd} - Contraseña para el inicio de sesión
#   ${admin_email} - Correo electrónico
#   ${admin_firstname} - Primer nombre
#   ${admin_lastname} - Apellido
bin/magento admin:user:create --admin-user="${admin_user}" --admin-password="${admin_pwd}" --admin-email="${admin_email}" --admin-firstname="${admin_firstname}" --admin-lastname="${admin_lastname}"
# Importar páginas y bloques del CMS
find .cms -type f -exec bin/magento cms:import {} \;
# Read and apply DEPLOYNOTES.md
