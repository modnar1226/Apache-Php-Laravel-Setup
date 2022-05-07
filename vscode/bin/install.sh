#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo "Must be root to run!";
    exit
fi

if dpkg-query -l | grep "code-insiders" &>/dev/null ;
    then
        echo "Vs Code - Insiders already installed";
    else
        echo "Installing VS Code-insiders.";
        curl -o code-insiders.deb -L https://go.microsoft.com/fwlink/?LinkID=760868
        code-insiders.deb
        dpkg -i code-insiders.deb
        rm code-insiders.deb
    fi