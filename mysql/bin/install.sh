#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if dpkg-query -l | grep "mysql" &>/dev/null
    then
        echo "Mysql already installed.";
        echo "To start it run: ";
        echo "/etc/init.d/mysqld start";
	#echo "If you haven't set up a password use the following command";
    else
        apt-get update -y && apt-get install -y \
            mysql-server

        if dpkg-query -l | grep "mysql" &>/dev/null
        then
	    echo "Mysql Installed successfully";
        fi

    fi