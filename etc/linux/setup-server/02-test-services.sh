#!/bin/bash

# Conectarse por ssh a la máquina ec2
#   ${env_host} - Host para la conexión SSH
#   ${env_port} - Puero para la conexión SSH
#   ${env_user} - Usuario de la conexión SSH
#   ${env_key} - Llave para acceder por SSH a la instancia
ssh -i "${env_key}" -p "${env_port}" "${env_user}@${env_host}"
# Validar acceso desde la instancia EC2 a la RDS
#   ${mysql_host} - Nombre de host de la RDS
#   ${mysql_port} - Puerto para conexión con RDS
#   ${mysql_user} - Usuario para la conexión
#   ${mysql_database} - Nombre de la base de datos
mysql -h "${mysql_host}" -P "${mysql_port}" -u "${mysql_user}" -p "${mysql_database}"
# Validar el acceso desde la instancia EC2 a OpenSearch
#   ${os_host} - Nombre de host de OpenSearch
#   ${os_user} - Usuario para acceso
#   ${os_pwd} - Contraseña de acceso
curl "${os_host}" -i -u "${os_user}:${os_pwd}"
