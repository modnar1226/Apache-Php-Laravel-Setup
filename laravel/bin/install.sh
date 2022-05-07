#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if ls -la /home/$SUDO_USER/.composer/vendor/bin | grep "laravel" &>/dev/null
    then
        echo "Laravel already installed.";
        echo "To start a new project run:";
        echo "laravel new <project name>";
    else
        echo "Installing Laravel";
        
        cd /var/www/html/
        su - "$SUDO_USER" -c "composer global require laravel/installer"
    fi