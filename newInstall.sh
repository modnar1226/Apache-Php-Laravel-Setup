#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

installVsCode () {

    
    if dpkg-query -l | grep "code-insiders" &>/dev/null ;
    then
        echo "Vs Code - Insiders already installed";
    else
        echo "Installing VS Code-insiders.";
        curl -o code-insiders.deb -L https://go.microsoft.com/fwlink/?LinkID=760868
        code-insiders.deb
        dpkg -i code-insiders.deb
    fi
}

installDocker () {
    
    echo "Removing any older Docker installs.";

    apt-get remove docker docker-engine docker.io containerd runc
    
    echo "Curl Docker key.";
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    apt-get update -y && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        gnupg-agent \
        software-properties-common \

    echo "Add Docker Repository";
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

    echo "Installing Docker";
    apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io
}

installElasticsearch () {
    echo "Installing Elasticsearch with Security enabled.";
    dpkg -i elasticsearch.deb

    #echo 'xpack.security.enabled: true' >> /etc/elasticsearch/elasticsearch.yml;
    #echo 'xpack.ml.enabled: false' >> /etc/elasticsearch/elasticsearch.yml;

    echo "Start Elasticsearch as a Service.";
    systemctl daemon-reload
    
    # run as a service
    systemctl enable elasticsearch.service
    # start elastic service
    systemctl start elasticsearch.service


    echo "Setup Elastic Passwords.";
    . /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive
}

installKibana () {
    dpkg -i kibana.deb

    #KIBANA_HASH = hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random

    #echo "xpack.security.encryptionKey: \"$KIBANA_HASH\"" >> /etc/kibana/kibana.yml;
    echo "Set password to access Kibana:";
    #read -p "Enter the elastic user pass created previously:" ELASTIC_PASS;
    #sed -i 's/#elasticsearch.username: \"kibana\"/elasticsearch.username: \"elastic\"/1' /etc/kibana/kibana.yml
    #sed -i "s/#elasticsearch.password: \"pass\"/elasticsearch.password: \"$ELASTIC_PASS\"/1" /etc/kibana/kibana.yml
    
    echo "Starting Kibana as a Service";
    systemctl daemon-reload

    systemctl enable kibana.service

    systemctl start kibana.service
}

installApache () {

    if dpkg-query -l | grep "code-insiders" &>/dev/null ; 
    then
        echo "Apache2 already installed";
    else
        echo "Installing Apache2";
        apt-get update -y && apt-get install -y \
            apache2 \
            curl
        
        echo "Enable Rewrite";
        a2enmod rewrite
        chown -R $USER:www-data /var/www/html/
        chmod -R u-w /var/www/html/
        chmod -R g+rx /var/www/html/

        echo "Setup .htaccess rules and a virtual host @ http://inventory";
        cp ./000-default.conf /etc/apache2/sites-enabled/000-default.conf

        echo "Add inventory to /etc/hosts";
        

        echo "Restarting Apache.";
        systemctl restart apache2

        
        if curl -s "http://localhost/" | grep "Apache2 Ubuntu Default Page" &>/dev/null ;
        then
            echo "Apache Installed Successfully";
        else 
            echo "Apache Install Failure check settings @ /etc/apache2/"
        fi
}

installMysql () {
    apt-get update -y && apt-get install -y \
        mysql-server 

}

installPhp () {

    echo "Installing PHP.";

    apt-get update -y && apt-get install -y \
        php-xdebug \
        php-common \
        php-json \
        php-pear \
        php-fpm \
        php-dev \
        php-zip \
        php-curl \
        php-xmlrpc \
        php-gd \
        php-mysql \
        php-mbstring \
        php-xml \
        php7.2-bz2 \
        libapache2-mod-php 

    echo "Enabling X-debug remote @ /etc/php/7.2/cli/php.ini";
    echo "xdebug.remote_enable=1"        >> /etc/php/7.2/cli/php.ini
    echo "Enabling X-debug remote auto_start @ /etc/php/7.2/cli/php.ini";
    echo "xdebug.remote_autostart=1"     >> /etc/php/7.2/cli/php.ini
    echo "Setting X-debug IDE key @ /etc/php/7.2/cli/php.ini";
    echo "xdebug.idekey=VSCODE"          >> /etc/php/7.2/cli/php.ini
    echo "Setting X-debug remote_host to 127.0.0.1 @ /etc/php/7.2/cli/php.ini";
    echo "xdebug.remote_host=127.0.0.1"  >> /etc/php/7.2/cli/php.ini 
    echo "Setting X-debug remote_port to 9000 @ /etc/php/7.2/cli/php.ini";
    echo "xdebug.remote_port=9000"       >> /etc/php/7.2/cli/php.ini 
    echo "Disabling X-debug remote_connect_back @ /etc/php/7.2/cli/php.ini";
    echo "xdebug.remote_connect_back=0"  >> /etc/php/7.2/cli/php.ini
    echo "Seting zend_extension to xdbug.so @ /etc/php/7.2/cli/php.ini";
    echo "zend_extension=xdebug.so"      >> /etc/php/7.2/cli/php.ini
}

installComposer () {
    
    echo "Installing Composer";
    
    EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
    then
        >&2 echo 'ERROR: Invalid installer signature'
        rm composer-setup.php
        exit 1
    fi

    php composer-setup.php --install-dir-=/usr/local/bin --filename=composer --quiet
    RESULT=$?
    rm composer-setup.php
    chown -R $USER:$USER /home/$USER/.composer
    echo "PATH=$PATH:/home/$USER/.composer/vendor/bin" >> /home/$USER/.profile
    source /home/$USER/.profile
}

installLaravel () {
    
    echo "Installing Laravel with project: inventory @ /var/www/html";
    
    cd /var/www/html/
    su - "$USER" -c "composer global require laravel/installer"
    laravel new inventory
    chown -R $USER:www-data inventory
    chmod -R g+w ./inventory/storage/
    chmod -R g+w ./inventory/bootstrap/cache
}

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            echo "Requirements: Ubuntu version 16 +";
            echo "";
            echo "Usage: ./newInstall <option>";
            echo "";
            echo "           Flag          |          Description           ";
            echo "----------------------------------------------------------";
            echo "-A OR --all            : Install all available packages and dependancies (Apache1, Composer,Docker, Elasticsearch, Kibana, Mysql, Php, Vs Code)";
            echo "";
            echo "-a OR --apache         : Install Apache2 and dependancies";
            echo "-c OR --composer       : Install Composer and dependancies";
            echo "-d OR --docker         : Install Docker and dependancies";
            echo "-e OR --elastic        : Install Elasticsearch and dependancies";
            echo "-k OR --kibana         : Install Kibana and dependancies";
            echo "-m OR --mysql          : Install Mysql and dependancies";
            echo "-p OR --php            : Install PHP7 and dependancies";
            echo "-v OR --vscode         : Install Vs Code and dependancies";
            exit
            ;;
        -A|--all)
            installApache
            installMysql
            installPhp
            installComposer
            installDocker
            installElasticsearch
            installKibana
            installVsCode
            apt-get update -y
            exit
            ;;
        -a|--apache)
            installApache
            apt-get update -y
            exit
            ;;
        -c|--composer)
            installApache
            apt-get update -y
            exit
            ;;
        -d|--docker)
            installDocker
            apt-get update -y
            exit
            ;;
        -e|--elastic)
            installElasticsearch
            apt-get update -y
            exit
            ;;
        -k|--kibana)
            installKibana
            apt-get update -y
            exit
            ;;
        -m|--mysql)
            installApache
            apt-get update -y
            exit
            ;;
        -p|--php)
            installPhp
            apt-get update -y
            exit
            ;;
        -v|--vscode)
            installVsCode
            #apt-get update -y
            exit
            ;;
        *)
            echo "Invalid Parameter, use --help to see available commands";
            exit
            ;;
    esac
done

echo "You must enter a parameter, use --help for more info.";