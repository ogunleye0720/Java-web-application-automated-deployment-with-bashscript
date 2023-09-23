#!/bin/bash

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

#Installation without prompts
export DEBIAN_FRONTEND=noninteractive

# Check if the linux distribution is ubuntu
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    LINUX_DISTRIBUTION=$ID_LIKE
    #echo -e "$Green \n This is a debian linux distribution !!! $Color_off"
elif [[ -f /etc/redhat-release ]]; then
    LINUX_DISTRIBUTION="centos"

fi

# Function to check if a package is installed
function isPackageInstalled() {
    sudo dpkg-query -W -f='${Status}\n' "$1" 2>/dev/null | grep -c "install ok installed" 
}
 #Function to install and configure rabbit mq
function rabbitMq() {
    #Install dependencies
    if ! isPackageInstalled apt; then
            echo -e "$Red \n apt is not installed !!! $Color_off"
            echo -e "$Cyan \n Installing apt... $Color_off"
            
            sudo apt update -y
            sudo apt -y install apt-file
    else
            echo -e "$Green \n apt file is present !!! $Color_off"
            echo -e "$Cyan \n Updating apt repository... $Color_off"
            sudo apt update -y && sudo apt upgrade -y
    fi

    #Install curl, gnup and enable apt https transport
    sudo apt install curl wget gnupg apt-transport-https -y

    #Checks if curl is installed
    echo -e "$Cyan \n Checking if curl is installed... $Color_off"
    if isPackageInstalled curl; then
            echo -e "$Cyan \n Installing Team RabbitMQ's main signing key... $Color_off"
            curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
            echo "deb http://dl.bintray.com/rabbitmq-erlang/debian xenial erlang-22.x" | sudo tee  /etc/apt/sources.list.d/bintray.erlang.list > /dev/null
            sudo apt-get update -y
    
    else
            echo -e "$Red \n curl is not installed !!! $Color_off"
    fi

    echo -e "$Cyan \n Adding apt repositories maintained by Team RabbitMQ... $Color_off"
    wget https://www.rabbitmq.com/rabbitmq-signing-key-public.asc

    echo -e "$Cyan \n Updating package indices... $Color_off"
    sudo apt-get update -y && sudo apt-get upgrade -y

    echo -e "$Red \n Installing Erlang packages... $Color_off"
    sudo apt-get install -y erlang-base  erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key erlang-runtime-tools erlang-snmp erlang-ssl erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl
    echo -e "$Green \n Installing Erlang packages complete !!! $Color_off"

    #check if rabbitmq-server is installed
    echo -e "$Cyan \n  Checking if rabbitmq-server is installed... $Color_off"
    if isPackageInstalled rabbitmq-server; then
            echo -e "$Green \n  rabbitmq-server is installed already !!! $Color_off"
    else
        echo -e "$Cyan \n  Installing rabbitmq-server and its dependencies... $Color_off"
        sudo apt-get install curl gnupg -y
        curl -fsSL https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc | sudo apt-key add -
        echo "deb https://dl.bintray.com/rabbitmq/debian xenial main" | sudo tee /etc/apt/sources.list.d/bintray.rabbitmq.list
        sudo apt-get update -y
        sudo apt-get install rabbitmq-server -y 

        echo -e "$Cyan \n   Starting & Enabling rabbitMq-server... $Color_off"
        sudo systemctl start rabbitmq-server
        sudo systemctl enable rabbitmq-server

        #Addding test user to rabbitmq
        echo -e "$Cyan \n  Adding Test user to rabbitmq... $Color_off"
        sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'
        sudo rabbitmqctl add_user test test
        sudo rabbitmqctl set_user_tags test administrator
        sudo systemctl restart rabbitmq-server
    fi

    #Checks if RabbitMq is running
    echo -e "$Cyan \n  checking if rabbitmq-server is running... $Color_off"
    
    if sudo systemctl is-active --quiet rabbitmq-server; then
            echo -e "$Green \n RabbitMq Is Running !!! $Color_off"

            echo -e "$Green \n ==========================================================================================================================
     =    ==  =======  ===      ===        =====  =====  ========  ===========  =====        ==    ====    ====  =======  =
     ==  ===   ======  ==  ====  =====  =======    ====  ========  ==========    =======  ======  ====  ==  ===   ======  =
     ==  ===    =====  ==  ====  =====  ======  ==  ===  ========  =========  ==  ======  ======  ===  ====  ==    =====  =
     ==  ===  ==  ===  ===  ==========  =====  ====  ==  ========  ========  ====  =====  ======  ===  ====  ==  ==  ===  =
     ==  ===  ===  ==  =====  ========  =====  ====  ==  ========  ========  ====  =====  ======  ===  ====  ==  ===  ==  =
     ==  ===  ====  =  =======  ======  =====        ==  ========  ========        =====  ======  ===  ====  ==  ====  =  =
     ==  ===  =====    ==  ====  =====  =====  ====  ==  ========  ========  ====  =====  ======  ===  ====  ==  =====    =
     ==  ===  ======   ==  ====  =====  =====  ====  ==  ========  ========  ====  =====  ======  ====  ==  ===  ======   =
     =    ==  =======  ===      ======  =====  ====  ==        ==        ==  ====  =====  =====    ====    ====  =======  =
     ======================================================================================================================
     ===================================================================================================================== 
     ==      ===  ====  ====     =====     ===        ===      ====      ===        ==  ====  ==  =============  ==  ==  = 
     =  ====  ==  ====  ===  ===  ===  ===  ==  ========  ====  ==  ====  ==  ========  ====  ==  =============  ==  ==  = 
     =  ====  ==  ====  ==  ========  ========  ========  ====  ==  ====  ==  ========  ====  ==  =============  ==  ==  = 
     ==  =======  ====  ==  ========  ========  =========  ========  =======  ========  ====  ==  =============  ==  ==  = 
     ====  =====  ====  ==  ========  ========      =======  ========  =====      ====  ====  ==  =============  ==  ==  = 
     ======  ===  ====  ==  ========  ========  =============  ========  ===  ========  ====  ==  =============  ==  ==  = 
     =  ====  ==  ====  ==  ========  ========  ========  ====  ==  ====  ==  ========  ====  ==  ======================== 
     =  ====  ==   ==   ===  ===  ===  ===  ==  ========  ====  ==  ====  ==  ========   ==   ==  =============  ==  ==  = 
     ==      ====      =====     =====     ===        ===      ====      ===  =========      ===        =======  ==  ==  = 
==============================================================================================================================  $Color_off"

    else
        echo -e "$Red \n  ______  _____   _____    ____   _____   _  _  _ 
    |  ____||  __ \ |  __ \  / __ \ |  __ \ | || || |
    | |__   | |__) || |__) || |  | || |__) || || || |
    |  __|  |  _  / |  _  / | |  | ||  _  / | || || |
    | |____ | | \ \ | | \ \ | |__| || | \ \ |_||_||_|
    |______||_|  \_\|_|  \_\ \____/ |_|  \_\(_)(_)(_) $Color_off"   

              echo -e "$Red \n Rabbitmq-server Is Not Running!!! Troubleshoot Now !!! $Color_off"
    fi
}

if [[ $LINUX_DISTRIBUTION == 'debian' ]]; then
       rabbitMq
fi  