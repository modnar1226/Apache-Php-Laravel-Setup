#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

while test $# -gt 0; do
    case "$1" in
        -h|--help)
            ./displayhelp.sh
            exit
            ;;
        -A|--all)
            ./apache2/bin/install.sh
            ./mysql/bin/install.sh
            ./php/bin/install.sh
            ./composer/bin/install.sh
            ./laravel/bin/install.sh
            ./docker/bin/install.sh
            ./elasticsearch/bin/install.sh
            ./kibana/bin/install.sh
            ./vscode/bin/install.sh
            ./phpmyadmin/bin/install.sh
            exit
            ;;
        -a|--apache)
            ./apache2/bin/install.sh
            exit
            ;;
        -c|--composer)
            ./composer/bin/install.sh
            exit
            ;;
        -d|--docker)
            ./docker/bin/install.sh
            exit
            ;;
        -e|--elastic)
            ./elasticsearch/bin/install.sh
            exit
            ;;
        -k|--kibana)
            ./kibana/bin/install.sh
            exit
            ;;
        -l|--laravel)
            ./laravel/bin/install.sh
            exit
            ;;
        --lamp)
            ./apache2/bin/install.sh
            ./mysql/bin/install.sh
            ./php/bin/install.sh
	    if dpkg-query -l | grep "mysql" &>/dev/null
            then
	        echo "You must change your password.";
                echo "Open a new terminal and run the folowing commands:";
                echo "sudo mysql -uroot";
                echo "ALTER USER 'root'@'localhost'IDENTIFIED WITH mysql_native_password BY 'your new password';";
                echo "exit";
                echo "sudo /etc/init.d/mysql restart";

            fi
            exit
            ;;
        -m|--mysql)
            ./mysql/bin/install.sh
            exit
            ;;
        -p|--php)
            ./php/bin/install.sh
            exit
            ;;
        -pma|--pma)
            ./phpmyadmin/bin/install.sh
            exit
            ;;
        -v|--vscode)
            ./vscode/bin/install.sh
            exit
            ;;
        *)
            echo "Invalid Parameter, use -h OR --help to see all available commands";
            exit
            ;;
    esac
done

./displayhelp.sh
