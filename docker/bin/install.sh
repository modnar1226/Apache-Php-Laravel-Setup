#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if dpkg-query -l | grep "docker" &>/dev/null
    then
        echo "Docker already installed, to start it run dockerd ";
    else
        echo "Removing any older Docker installs.";

        apt-get remove docker docker-engine docker.io containerd runc
        
        echo "Curl Docker key.";
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

        apt-get update -y && apt-get install -y \
            curl \
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
    fi