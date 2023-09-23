#!/bin/bash

#Installation without prompts
export DEBIAN_FRONTEND=noninteractive

#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

# Function to check if a package is installed
function isPackageInstalled() {
    sudo dpkg-query -W -f='${Status}\n' "$1" 2>/dev/null | grep -c "install ok installed" 
}

# Check if the linux distribution is ubuntu
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    LINUX_DISTRIBUTION=$ID_LIKE
    #echo -e "$Green \n This is a debian linux distribution !!! $Color_off"
elif [[ -f /etc/redhat-release ]]; then
    LINUX_DISTRIBUTION="centos"

fi

#Function to install and configure memcache
function memcache() {
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

    #Installs Memcached
    #Checks if memcached is installed
    echo -e "$Cyan \n  checking if memcached is running... $Color_off"


    #Checks if memcache is running
    echo -e "$Cyan \n  checking if memcached is installed... $Color_off"
    if isPackageInstalled memcached; then 
            echo -e "$Green \n memcached is installed... $Color_off"
    else
            echo -e "$Cyan \n  Installing Memcache... $Color_off"  
            sudo apt install -y memcached libmemcached-tools
            echo -e "$Green \n  =================================================================================================
        =  =====  ==        ==  =====  ====     ======  =======     ===  ====  ==        ==       ==
        =   ===   ==  ========   ===   ===  ===  ====    =====  ===  ==  ====  ==  ========  ====  =
        =  =   =  ==  ========  =   =  ==  =========  ==  ===  ========  ====  ==  ========  ====  =
        =  == ==  ==  ========  == ==  ==  ========  ====  ==  ========  ====  ==  ========  ====  =
        =  =====  ==      ====  =====  ==  ========  ====  ==  ========        ==      ====  ====  =
        =  =====  ==  ========  =====  ==  ========        ==  ========  ====  ==  ========  ====  =
        =  =====  ==  ========  =====  ==  ========  ====  ==  ========  ====  ==  ========  ====  =
        =  =====  ==  ========  =====  ===  ===  ==  ====  ===  ===  ==  ====  ==  ========  ====  =
        =  =====  ==        ==  =====  ====     ===  ====  ====     ===  ====  ==        ==       ==
================================================================================================================================== $Color_off"
            echo -e "$Cyan \n  Starting Memcached service... $Color_off"
            sudo systemctl start memcached
            echo -e "$Cyan \n  Enabling Memcached service... $Color_off"
    fi
    
    if sudo systemctl is-active --quiet memcached; then
            echo -e "$Green \n memcached Is Running !!! $Color_off"

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

              echo -e "$Red \n memcached server Is Not Running!!! Troubleshoot Now !!! $Color_off"
    fi

}

if [[ $LINUX_DISTRIBUTION == 'debian' ]]; then
    memcache
fi  
exit 0