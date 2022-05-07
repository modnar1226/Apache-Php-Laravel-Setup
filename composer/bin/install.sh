#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if ls -la  /bin | grep "composer" &>/dev/null
    then
        echo "Composer already installed globally @ /bin";
    elif ls -la  /usr/local/bin | grep "composer" &>/dev/null
    then
        echo "Composer already installed globally  @ /usr/local/bin";
    else
        echo "Installing composer globally @ /usr/local/bin";
        
        EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

        if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
        then
            >&2 echo 'ERROR: Invalid installer signature'
            rm composer-setup.php
            exit 1
        fi

        php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer --quiet
        RESULT=$?
        rm composer-setup.php
        chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config/composer
        echo "PATH=/home/$SUDO_USER/.composer/vendor/bin:$PATH" >> /home/$SUDO_USER/.profile
        source /home/$SUDO_USER/.profile

        if echo $PATH | grep ":/bin:" &>/dev/null
        then
            echo "Composer installed successfully.";
        else
            source /etc/envrionment
            sed -i '\|.composer/vendor/bin:$PATH|d' /home/$SUDO_USER/.profile
            source /home/$SUDO_USER/.profile
            echo "Composer could not be added to the your PATH.";
            echo "You must add ./composer/vendor/bin or .composer/config/vendor.bin to your PATH";
        fi
    fi