#!/bin/bash

# git styles
[ -f ~/.bash_gitrc ] && source ~/.bash_gitrc

# magento env move
env-move() { 
    [ -z "${1}" ] && echo "ERR~ No env-name provided" && return 1
    [ ! -d /magento-app/"${1}" ] && echo "ERR~ No env found for '${1}'" && return 1
    cd /magento-app/"${1}"/site && return 0
}
