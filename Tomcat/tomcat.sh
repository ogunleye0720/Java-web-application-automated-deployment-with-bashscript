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

#Function to check if JDK11 is installed and install if not
function check_jdk() {
    if [[ $(java -version 2>&1) == *"OpenJDK"* ]]; then
        echo -e "$Yellow \n JDK 11 is already installed !!! $Color_off"
    else
        echo -e "$Cyan \n installing JDK 11... $Color_off"
        sudo apt-get update -y && sudo apt get upgrade -y
        sudo apt-get install -y openjdk-11-jdk

        echo -e "$Green \n ================================================================
     =====    ==       ===  ====  ==========  ========  ====
     ======  ===  ====  ==  ===  ==========   =======   ====
     ======  ===  ====  ==  ==  ============  ========  ====
     ======  ===  ====  ==  =  =============  ========  ====
     ======  ===  ====  ==     =============  ========  ====
     ======  ===  ====  ==  ==  ============  ========  ====
     =  ===  ===  ====  ==  ===  ===========  ========  ====
     =  ===  ===  ====  ==  ====  ==========  ========  ====
     ==     ====       ===  ====  ========      ====      ==
======================================================= $Color_off"
    fi
}

#Function to install Tomcat 9
function install_tomcat() {
    if isPackageInstalled "tomcat9"; then
        echo -e "$Yellow \n tomcat 9 is installed already !!! $Color_off"
    else
        #Install tomcat9 
        echo -e "$Cyan \n installing tomcat 9 and dependencies... $Color_off"
        sudo apt-get update -y
        sudo apt-get -y install tomcat9 tomcat9-admin tomcat9-docs tomcat9-common git 
    fi
}

# Check if the linux distribution is ubuntu
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    LINUX_DISTRIBUTION=$ID_LIKE
    #echo -e "$Green \n This is a debian linux distribution !!! $Color_off"
elif [[ -f /etc/redhat-release ]]; then
    LINUX_DISTRIBUTION="centos"
fi

function tomcat() {
    if ! isPackageInstalled apt; then
          echo -e "$Red \n apt is not installed !!! $Color_off"
          echo -e "$Cyan \n Installing apt... $Color_off"
          
          sudo apt update -y
          sudo apt -y install apt-file
    else
          echo -e "$Green \n apt file is present !!! $Color_off"
          echo -e "$Cyan \n Updating apt repository !!! $Color_off"
          sudo apt update -y && sudo apt upgrade -y
    fi
    #Install Jdk
    check_jdk

    #Install Tomcat
    install_tomcat

    #Checks if tomcat9 is running
    echo -e "$Cyan \n  checking if Tomcat server is running... $Color_off"
    
    if sudo systemctl is-active --quiet tomcat9; then
            echo -e "$Green \n Tomcat9 Is Running !!! $Color_off"

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

              echo -e "$Red \n Tomcat9 Server Is Not Running!!! Troubleshoot Now !!! $Color_off"
    fi
}

if [[ $LINUX_DISTRIBUTION == 'debian' ]]; then
       tomcat
fi  