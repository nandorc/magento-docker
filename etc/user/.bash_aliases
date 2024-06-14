#!/bin/bash

# git styles
[ -f ~/.bash_gitrc ] && source ~/.bash_gitrc

# Source for mage tools
[ -f ~/.magetools/init.sh ] && source ~/.magetools/init.sh

# XDebug Functions
function xdebug() {
    [ "${1}" != "on" ] && [ "${1}" != "off" ] && echo -e "ERR~ You must specify a valid value for XDebug. It must be 'on' or 'off'" && return 1
    if [ "${1}" == "on" ]; then
        export XDEBUG_SESSION=1
    else
        unset XDEBUG_SESSION
    fi
}
