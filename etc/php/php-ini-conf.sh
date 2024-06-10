#!/bin/bash

# Get params
declare webserver=
declare php_version=8.1
while [ -n "${1}" ]; do
    if [ "${1}" == "--webserver" ]; then
        [ "${2}" != "apache" ] && [ "${2}" != "nginx" ] && echo -e "ERR~ target webserver must be apache or nginx" && exit 1
        webserver=${2} && shift
    elif [ "${1}" == "--php-version" ]; then
        ([ -z "${2}" ] || [ -n "$(echo "${2}" | grep "^-")" ]) && echo -e "ERR~ PHP version not defined" && exit 1
        php_version=${2} && shift
    fi
    shift
done

# Check target webserver
[ -z "${webserver}" ] && echo -e "ERR~ target webserver must be defined" && exit 1

# Check ini file dirs exists
declare ini_file_dirs=("/etc/php/${php_version}/apache2/php.ini")
[ "${webserver}" = "nginx" ] && ini_file_dirs=("/etc/php/${php_version}/fpm/php.ini" "/etc/php/${php_version}/cli/php.ini")
for ini_file_dir in "${ini_file_dirs[@]}"; do
    [ ! -f "${ini_file_dir}" ] && echo -e "ERR~ Can't find php.ini file to set recommended configurations at ${ini_file_dir}" && exit 1
done

# Set recommended configurations
declare settings=("date.timezone=America/Bogota" "max_execution_time=120" "memory_limit=2G" "post_max_size=64M" "upload_max_filesize=64M" "max_input_time=60" "max_input_vars=3000" "realpath_cache_size=10M" "realpath_cache_ttl=7200" "opcache.save_comments=1")
[ "${webserver}" = "nginx" ] && settings=("date.timezone=America/Bogota" "max_execution_time=1800" "memory_limit=2G" "post_max_size=64M" "upload_max_filesize=64M" "max_input_time=60" "max_input_vars=3000" "realpath_cache_size=10M" "realpath_cache_ttl=7200" "opcache.save_comments=1" "zlib.output_compression=On")
for ini_file_dir in "${ini_file_dirs[@]}"; do
    echo -e "INF~ STORE SETTINGS AT '${ini_file_dir}'"
    for setting in "${settings[@]}"; do
        setting=(${setting//=/ })
        current_value=$(cat "${ini_file_dir}" | grep "^${setting[0]}")
        if [ -n "${current_value}" ]; then
            current_value=(${current_value//=/ }) && current_value=${current_value[1]}
            [ "${current_value}" == "${setting[1]}" ] && echo -e "INF~ ${setting[0]} is already setted to ${setting[1]} at ${ini_file_dir}" && continue
            sed -i -e "s|^${setting[0]}\(.*\)|${setting[0]} = ${setting[1]}|" "${ini_file_dir}"
            res_cod=$?
        else
            current_value=$(cat "${ini_file_dir}" | grep "^;${setting[0]}")
            [ -z "${current_value}" ] && echo -e "ERR~ Can't find ${setting[0]} to set it as ${setting[1]} at ${ini_file_dir}" && exit 1
            sed -i -e "s|^;${setting[0]}\(.*\)|${setting[0]} = ${setting[1]}|" "${ini_file_dir}"
            res_cod=$?
        fi
        [ ${res_cod} -eq 0 ] && echo -e "INF~ ${setting[0]} was settet to ${setting[1]} at ${ini_file_dir}" && continue
        echo -e "WRN~ Couldn't set ${setting[0]} to ${setting[1]} at ${ini_file_dir}" && exit 1
    done
done
exit 0
