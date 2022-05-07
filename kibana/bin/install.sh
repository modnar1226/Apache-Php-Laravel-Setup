#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if dpkg-query -l | grep "kibana" &>/dev/null
    then
        echo "Kibana already installed.";
        echo "To start it run:";
        echo "sudo systemctl restart kibana.service";
        echo "To view the logs run:";
        echo "journalctl --unit kibana --since yyyy-mm-dd";
    else
        echo "Installing Kibana.";

        PWD=="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
        FILENAME=kibana.deb;
        FILE="$PWD$FILE";
        
        echo "Installing Elasticsearch.";

        if [ ! -f "$FILE" ]; then
            echo "$FILENAME exists"
        else 
            curl -o kibana.deb -L https://artifacts.elastic.co/downloads/kibana/kibana-7.2.1-amd64.deb
        fi
        dpkg -i kibana.deb

        #KIBANA_HASH = hexdump -n 16 -e '4/4 "%08X" 1 "\n"' /dev/random

        #echo "xpack.security.encryptionKey: \"$KIBANA_HASH\"" >> /etc/kibana/kibana.yml;
        #echo "Set password to access Kibana:";
        #read -p "Enter the elastic user pass created previously:" ELASTIC_PASS;
        #sed -i 's/#elasticsearch.username: \"kibana\"/elasticsearch.username: \"elastic\"/1' /etc/kibana/kibana.yml
        #sed -i "s/#elasticsearch.password: \"pass\"/elasticsearch.password: \"$ELASTIC_PASS\"/1" /etc/kibana/kibana.yml
        
        echo "Starting Kibana as a Service";
        systemctl daemon-reload

        systemctl enable kibana.service

        systemctl start kibana.service

        echo "To view logs run: journalctl --unit kibana --since yyyy-mm-dd";
    fi