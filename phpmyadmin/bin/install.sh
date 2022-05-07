#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

echo "Installing PhpMyAdmin";
    apt-get update -y && apt-get install -y \
        phpmyadmin

    ln -s /usr/share/phpmyadmin /var/www/html/
    a2enconf phpmyadmin.conf
    sudo service apache2 reload