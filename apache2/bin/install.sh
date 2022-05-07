#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if dpkg-query -l | grep "apache2" &>/dev/null
    then
        echo "Apache2 already installed";
    else
        echo "Installing Apache2";
        apt-get update -y && apt-get install -y \
            apache2 \
            modsecurity-crs

        echo "Download and Install Owasp Rule Set V3.3.2";
        curl -L -o /tmp/coreruleset3-3-2.tar.gz https://github.com/coreruleset/coreruleset/archive/v3.3.2.tar.gz
        tar -xvzf /tmp/coreruleset3-3-2.tar.gz -C /tmp/
        mkdir -p /etc/modsecurity/owasp/rules/
        cp /tmp/coreruleset-3.3.2/crs-setup.conf.example /etc/modsecurity/owasp/crs-setup.conf
        cp -r /tmp/coreruleset-3.3.2/rules/ /etc/modsecurity/owasp/
        rm /tmp/coreruleset3-3-2.tar.gz
        rm -r /tmp/coreruleset-3.3.2

        echo "Setup .htaccess rules and a virtual host @ http://www.example.com";
        cp ../site-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf

        echo "Enable Rewrite";
        apache2ctl -t
        a2enmod rewrite 
        chown -R $SUDO_USER:www-data /var/www/html/
        chmod -R u-w /var/www/html/
        chmod -R g+rx /var/www/html/


        echo "Restarting Apache.";
        systemctl restart apache2

        if dpkg-query -l | grep "apache2" &>/dev/null
        then
            echo "Apache Installed Successfully";
        else 
            echo "Apache Install Failure."
            echo "Check settings @ /etc/apache2/hosts";
            echo "Check settings @ /etc/apache2/sites-enabled/000-default.conf";
        fi
    fi