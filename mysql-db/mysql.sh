#!/bin/bash

#Installation without prompts
export DEBIAN_FRONTEND=noninteractive

#MYSQL query to check if anonymous user exist
CHECK_QUERY="SELECT user FROM mysql.user WHERE User='';"

# Execute the MYSQL query
result=$(sudo mysql -u root -p"$rootpass" -Bse "$CHECK_QUERY")

#Root Password and database parameters
rootpass='Root123#20'
dbname='accounts'
dbuser='lisa'      #'dbusername' 
dbpass='765'    #'dbpass123#20'

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

#Function to install and configure MYSQL on ubuntu
function ubuntuMysql() {
    #check if apt is installed
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

    #check if mysql installed
    echo -e "$Yellow \n checking if MYSQL is installed... $Color_off"
    if  ! isPackageInstalled mysql-server; then
          echo -e "$Red \n MYSQL is not installed !!! $Color_off"

          echo -e "$Cyan \n installing MYSQL... $Color_off"
          #Set MYSQL root password
          echo -e "$Cyan \n setting MYSQL root password... $Color_off"
          #Replace the rootpw with your desired root password !!!!
          echo "mysql-community-server mysql-community-server/root-pass password $rootpass" | debconf-set-selections     
          echo "mysql-community-server mysql-community-server/re-root-pass password $rootpass" | debconf-set-selections     
          #Install mysql-server
          sudo apt install wget -y
          sudo wget https://dev.mysql.com/get/mysql-apt-config_0.8.22-1_all.deb
          sudo apt update -y && sudo apt upgrade -y
          sudo apt install mysql-server mysql-client mysql-common -y

          echo -e "$Green \n MMMMMMMM               MMMMMMMMYYYYYYY       YYYYYYY   SSSSSSSSSSSSSSS      QQQQQQQQQ     LLLLLLLLLLL             
    M:::::::M             M:::::::MY:::::Y       Y:::::Y SS:::::::::::::::S   QQ:::::::::QQ   L:::::::::L             
    M::::::::M           M::::::::MY:::::Y       Y:::::YS:::::SSSSSS::::::S QQ:::::::::::::QQ L:::::::::L             
    M:::::::::M         M:::::::::MY::::::Y     Y::::::YS:::::S     SSSSSSSQ:::::::QQQ:::::::QLL:::::::LL             
    M::::::::::M       M::::::::::MYYY:::::Y   Y:::::YYYS:::::S            Q::::::O   Q::::::Q  L:::::L               
    M:::::::::::M     M:::::::::::M   Y:::::Y Y:::::Y   S:::::S            Q:::::O     Q:::::Q  L:::::L               
    M:::::::M::::M   M::::M:::::::M    Y:::::Y:::::Y     S::::SSSS         Q:::::O     Q:::::Q  L:::::L               
    M::::::M M::::M M::::M M::::::M     Y:::::::::Y       SS::::::SSSSS    Q:::::O     Q:::::Q  L:::::L               
    M::::::M  M::::M::::M  M::::::M      Y:::::::Y          SSS::::::::SS  Q:::::O     Q:::::Q  L:::::L               
    M::::::M   M:::::::M   M::::::M       Y:::::Y              SSSSSS::::S Q:::::O     Q:::::Q  L:::::L               
    M::::::M    M:::::M    M::::::M       Y:::::Y                   S:::::SQ:::::O  QQQQ:::::Q  L:::::L               
    M::::::M     MMMMM     M::::::M       Y:::::Y                   S:::::SQ::::::O Q::::::::Q  L:::::L         LLLLLL
    M::::::M               M::::::M       Y:::::Y       SSSSSSS     S:::::SQ:::::::QQ::::::::QLL:::::::LLLLLLLLL:::::L
    M::::::M               M::::::M    YYYY:::::YYYY    S::::::SSSSSS:::::S QQ::::::::::::::Q L::::::::::::::::::::::L
    M::::::M               M::::::M    Y:::::::::::Y    S:::::::::::::::SS    QQ:::::::::::Q  L::::::::::::::::::::::L
    MMMMMMMM               MMMMMMMM    YYYYYYYYYYYYY     SSSSSSSSSSSSSSS        QQQQQQQQ::::QQLLLLLLLLLLLLLLLLLLLLLLLL
                                                                                        Q:::::Q                       
                                                                                        QQQQQQ  $Color_off"
          # Install "expect"
          sudo apt-get -qq install expect > /dev/null
          sudo apt update -y && sudo apt upgrade -y

          #Wait for 2 seconds
          echo -e "$Purple \n sleeping for 2 seconds... $Color_off"
          sleep 2
          
          echo -e "$Yellow \n Reseting MYSQL root password... $Color_off"
          sudo mysql -u root -p"$rootpass" -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$rootpass';"
          #Secure MYSQL installation
          echo -e "$Yellow \n Securing MYSQL installation... $Color_off"
          # Generate an expect script
          tee ~/secure_mysql.sh > /dev/null << EOF
            spawn $(which mysql_secure_installation)

            #Enter password for user root
            expect "Enter password for user root:"
            send "$rootpass"
            send "\r"

            # Would you like to setup the validate Password Plugin?
            expect "Would you like to setup VALIDATE PASSWORD component?"
            send "n\r"

            # Change the password for root?
            expect "Change the password for root ? ((Press y|Y for Yes, any other key for No) :"
            send "y\r"

            # set the new root password
            expect "New password:"
            send "$rootpass\r"

            # Confirm the new root password
            expect "Re-enter new password:"
            send "$rootpass\r"

            # Continue with secure nysql
            expect "Do you wish to continue with the existing password? (Press y|Y for yes, any other key for No) :"
            send "n\r"

            # Remove anonymous users
            expect "Remove anonymous users? (Press y|Y for Yes, any other key for No) :"
            send "y\r"

            # Disallow remote root login
            expect "Disallow root login remotely? (Press y|Y for Yes, any other key for No) :"
            send "y\r"

            # Remove test DB?
            expect "Remove test database and access to it? (Press y|Y for Yes, any other key for No) :"
            send "y\r"

            # Reload privilege tables
            expect "Reload privilege tables now? (Press y|Y for Yes, any other key for No) :"
            send "y\r"

            
            # Exit the script
            expect eof
EOF
            # Run Expect script.
            # This runs the "mysql_secure_installation" script which removes insecure defaults.
            sudo expect ~/secure_mysql.sh

            # Cleanup
            rm -v ~/secure_mysql.sh # Remove the generated Expect script
    else 
            echo -e "$Green \n MYSQL Is Installed already !!! $Color_off"
    fi
         echo -e "$Purple \n Creating Database "$dbname" and Database User "$dbuser"... $Color_off"
         echo -e "$Purple \n Checking if Database "$dbname" and Database User "$dbuser"  Exist...$Color_off"

         echo -e "$Cyan \n Checking if Database "$dbname"  Exist...$Color_off"
         if sudo mysqlshow -u root -p"$rootpass" $dbname >/dev/null 2>&1; then
              echo -e "$Red \n Database $dbname already exist... $Color_off"
         else 
              echo -e "$Purple \n Creating Database $dbname... $Color_off"
              sudo mysql -u root -p"$rootpass" -e "CREATE DATABASE $dbname;"
         fi
         echo -e "$Cyan \n Checking if Database User "$dbuser"  Exist...$Color_off"
         if   sudo mysql -u root -p"$rootpass" -e "SELECT User FROM mysql.user WHERE User='$dbuser'" | grep -q "$dbuser"; then
              echo -e "$Red \n Database User $dbuser already exist... $Color_off"
         else 
              echo -e "$Yellow \n Creating Database User $dbuser... $Color_off" 
              sudo mysql -u root -p"$rootpass" -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';" 
              echo -e "$Yellow \n Granting All Privileges on Database $dbname to $dbuser... $Color_off"
              sudo mysql -u root -p"$rootpass" -e "GRANT ALL ON $dbname.* TO '$dbuser'@'localhost' WITH GRANT OPTION;" 
              echo -e "$Cyan \n Flushing Privileges... $Color_off"
              sudo mysql -u root -p"$rootpass" -e "FLUSH PRIVILEGES;"

              # Check if anonymous user still exits
              echo -e "$Purple \n Checking if anonymous user still exist...$Color_off"
              if [[ -n "$result" ]]; then

                   echo -e "$Red \n Anonymous user still exists, removing... $Color_off"

                   #MYSQL command to remove the anonymous user
                   REMOVE_QUERY="DELETE FROM mysql.user WHERE User=''; FLUSH PRIVILEGES;"

                   #Execute the MYSQL command to remove the anonymous user
                   sudo mysql -u root -p"$rootpass" -e "$REMOVE_QUERY"
                   echo -e "$Green \n Anonymous user removed Successfuly !!! $Color_off"
              else
                   echo -e "$Yellow \n Anonymous user does not exist !!! $Color_off"
              fi

              echo -e "$Green \n Database '$dbname' and '$dbuser' has been created successfuly !!! $Color_off" 
         fi

         echo -e "$Cyan \n Restarting MYSQL...$Color_off"
         sudo systemctl restart mysql

         if sudo systemctl is-active --quiet mysql; then
              echo -e "$Green \n MYSQL Is Running !!!!! $Color_off"

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

              echo -e "$Red \n MYSQL Is Not Running!!!!! Troubleshot Now !!! $Color_off"   
         fi
}

if [[ $LINUX_DISTRIBUTION == 'debian' ]]; then
       ubuntuMysql
fi  