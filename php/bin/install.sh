#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if dpkg-query -l | grep "php7" &>/dev/null
    then
        echo "PHP7 already installed.";
        echo "To verify it run: ";
        echo "php -i";
    else
        echo "Installing PHP.";

        apt-get update -y && apt-get install -y \
            php \
            php-bcmath \
            php-bz2 \
            php-cli \
            php-common \
            php-curl \
            php-fpm \
            php-gd \
            php-gmp \
            php-json \
            php-ldap \
            php-mbstring \
            php-mysql \
            php-pear \
            php-soap \
            php-sqlite3 \
            php-tidy \
            php-xml \
            php-zip \
            libapache2-mod-security2

        #echo "Enabling X-debug remote @ /etc/php/7.2/cli/php.ini";
        #echo "xdebug.remote_enable=1"        >> /etc/php/7.2/cli/php.ini
        #echo "Enabling X-debug remote auto_start @ /etc/php/7.2/cli/php.ini";
        #echo "xdebug.remote_autostart=1"     >> /etc/php/7.2/cli/php.ini
        #echo "Setting X-debug IDE key @ /etc/php/7.2/cli/php.ini";
        #echo "xdebug.idekey=VSCODE"          >> /etc/php/7.2/cli/php.ini
        #echo "Setting X-debug remote_host to 127.0.0.1 @ /etc/php/7.2/cli/php.ini";
        #echo "xdebug.remote_host=127.0.0.1"  >> /etc/php/7.2/cli/php.ini 
        #echo "Setting X-debug remote_port to 9000 @ /etc/php/7.2/cli/php.ini";
        #echo "xdebug.remote_port=9000"       >> /etc/php/7.2/cli/php.ini 
        #echo "Disabling X-debug remote_connect_back @ /etc/php/7.2/cli/php.ini";
        #echo "xdebug.remote_connect_back=0"  >> /etc/php/7.2/cli/php.ini
        #echo "Seting zend_extension to xdbug.so @ /etc/php/7.2/cli/php.ini";
        #echo "zend_extension=xdebug.so"      >> /etc/php/7.2/cli/php.ini
    fi