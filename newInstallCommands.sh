#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

installVsCode () {
    echo "Installing VS Code-insiders.";
    apt install ./code-insiders.deb
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
    /bin/systemctl daemon-reload
    
    # run as a service
    /bin/systemctl enable elasticsearch.service
    # start elastic service
    systemctl start elasticsearch.service


    echo "Setup Elastic Passwords.";
    /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive
}

installKibana () {
    dpkg -i kibana.deb

    KIBANA_HASH = hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random

    #echo "xpack.security.encryptionKey: \"$KIBANA_HASH\"" >> /etc/kibana/kibana.yml;
    echo "Set password to access Kibana:";
    #read -p "Enter the elastic user pass created previously:" ELASTIC_PASS;
    #sed -i 's/#elasticsearch.username: \"kibana\"/elasticsearch.username: \"elastic\"/1' /etc/kibana/kibana.yml
    #sed -i "s/#elasticsearch.password: \"pass\"/elasticsearch.password: \"$ELASTIC_PASS\"/1" /etc/kibana/kibana.yml
    
    echo "Starting Kibana as a Service";
}

installApache () {
    echo "Installing Apache2";
    apt-get update -y && apt-get install -y \
        apache2 \
        curl
    
    echo "Enable Rewrite";
    a2enmod rewrite
    chown -R $USER:www-data /var/www/html/
    chmod -R u-w /var/www/html/
    chmod -R g+rx /var/www/html/

    echo "Setup .htaccess rules and a virtual host";
    cp ./000-default.conf /etc/apache2/sites-enabled/000-default.conf
    

    echo "Restarting Apache.";
    systemctl restart apache2

}

installMysql () {
    apt-get update -y && apt-get install -y \
        mysql-server 

}

installPhp () {
    apt-get update -y && apt-get install -y \
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
}

installComposer () {
    echo "Installing Composer";
    php installer
    echo "Making Composer Global";
    mv composer.phar /usr/local/bin/composer
    chown -R $USER:$USER /home/$USER/.composer
    echo "PATH=PATH:/home/$USER/.composer/vendor/bin" >> /home/$USER/.profile

}

installLaravel () {
    echo "Installing Laravel";
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
            echo "-a OR --apache         : Install Apache2 and dependancies";
            echo "-c OR --composer         : Install Composer and dependancies";
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
            #installElasticsearch
            #installKibana
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
            apt-get update -y
            exit
            ;;
        *)
            echo "Invalid Parameter, use --help to see available commands";
            exit
            ;;
    esac
done

echo "You must enter a parameter, use --help for more info.";