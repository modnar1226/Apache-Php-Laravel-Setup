#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if dpkg-query -l | grep "elasticsearch" &>/dev/null
    then
        echo "Elasticsearch already installed.";
        echo "To start it run: sudo systemctl restart elasticsearch.service";
        echo "To view the logs: journalctl --unit elasticsearch --since yyyy-mm-dd";
    else
        PWD=="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
        FILENAME=elasticsearch.deb;
        FILE="$PWD$FILE";
        
        echo "Installing Elasticsearch.";

        if [ ! -f "$FILE" ]; then
            echo "$FILENAME exists"
        else 
            curl -o elasticsearch.deb -L https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.2.1-amd64.deb
        fi

        dpkg -i elasticsearch.deb
        #echo 'xpack.security.enabled: true' >> /etc/elasticsearch/elasticsearch.yml;
        #echo 'xpack.ml.enabled: false' >> /etc/elasticsearch/elasticsearch.yml;

        echo "Starting Elasticsearch as a Service.";
        systemctl daemon-reload
        
        # run as a service
        systemctl enable elasticsearch.service
        # start elastic service
        systemctl start elasticsearch.service

        #echo "Setup Elastic Passwords.";
        #cd /usr/share/elasticsearch/bin/
        #./elasticsearch-setup-passwords interactive

        echo "To view logs run: journalctl --unit elasticsearch --since yyyy-mm-dd";
    fi