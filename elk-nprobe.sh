#!/bin/bash
#
# ntop.org & qxip.net - Experimental nProbe + ELK Installer
# Description: This script will automatically install and configure nProbe + Logstash, Elasticsearch and Kibana3
#
###############################################

CWD=$(pwd)

# Determine OS
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    OS=Debian  
    VER=$(cat /etc/debian_version)
else
    OS=$(uname -s)
    VER=$(uname -r)
    echo "$OS/$VER not yet supported!"
    exit 0;
fi

echo "  ...............................................   "
echo " ..................................................  "
echo " .................   .............................,. "
echo " .................   .............................,. "
echo " ....... '.    ..     '...    ..... .'   .........,. "
echo " ,,,,,,         '      ..      ',,        ,,,,,,,,,. "
echo " ,,,,,,    .'   ,      ,        ,,         ,,,,,,,,. "
echo " ,,,,,,   ,,,   ,,   ,,.   ,,.  ',   ,,,   ,,,,,,,,. "
echo " ,,,,,,   :::   ::   ::'  ::::   :   :::,  .,,,,,,,. "
echo " ,:::::   :::   ::   ::   ::::   :   ::::  .:::::,,. "
echo " ::::::   :::   ::   ::.  ,:::   :   :::'  :::::::,. "
echo " ::::::   :::   ::   :::   .,   ::    ,'   :::::::,. "
echo " ::::::   :::   ::   :::'       ::        .:::::::,. "
echo " :::::::  ::::  :::  ::::'     :::       .::::::::,. "
echo " :::::::::::::::::::::::::::::::::   :::::::::::::,. "
echo " :::::::::::::::::::::::::::::::::   :::::::::::::,. "
echo " :::::::::::::::::::::::::::::::::  .:::::::::::::,. "
echo "  ,::::::::::::::::::::::::::::::::::::::::::::::,.  "
echo
echo "   ntop.org - Experimental nProbe + ELK Installer"
echo "              os: $OS/$VER"
echo
echo "## Would you like to install nProbe (unlicensed)? [Y/n]: "
    read  setNPROBE
    case $setNPROBE in
        Y|y)
            # OS IF
            if [ "$OS" == "Ubuntu" ]; then
                echo 'Installing nProbe from ntop Ubuntu repository...'
                echo "deb http://www.nmon.net/apt x64" > /etc/apt/sources.list.d/ntop.list
                echo "deb http://www.nmon.net/apt all" >> /etc/apt/sources.list.d/ntop.list
                wget -O - http://www.nmon.net/apt/ntop.key | apt-key add -
                sudo apt-get update
                apt-get install -y --force-yes default-jdk rubygems ruby1.9.1-dev libcurl4-openssl-dev git apache2 libzmq-dev
                sudo apt-get install nprobe
            elif [ "$OS" == "Debian" ]; then
                echo 'Installing nProbe for stock Debian (+ static libs)...'
                apt-get install build-essential automake autoconf libtool alien
                apt-get install -y --force-yes default-jdk rubygems ruby1.9.1-dev libcurl4-openssl-dev git apache2 libzmq-dev
                ######### manually install zeromq3 #################
                cd /usr/src
                wget http://download.zeromq.org/zeromq-3.2.4.tar.gz
                tar zxvf zeromq-3.2.4.tar.gz
                cd zeromq-3.2.4
                ./configure
                ./make && make install
                ########## semi-manual installation of the static requirements #########
                apt-get install libmysqlclient-dev libssl-dev libnuma-dev
                ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so.18 /usr/lib/x86_64-linux-gnu/libmysqlclient.so.16
                ln -s /usr/lib/x86_64-linux-gnu/libssl.so.1.0.0 /usr/lib/x86_64-linux-gnu/libssl.so.10
                ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/x86_64-linux-gnu/libcrypto.so.10
                cd /usr/src
                wget http://ftp.us.debian.org/debian/pool/main/m/mysql-5.1/libmysqlclient16_5.1.73-1_amd64.deb
                dpkg -i libmysqlclient16_5.1.73-1_amd64.deb 
                rm -rf libmysqlclient16_5.1.73-1_amd64.deb
                ################################ nProbe ################################
                cd /usr/src
                latest=$(curl -s -l http://www.nmon.net/packages/rpm/x64/nProbe/ | grep x86_64.rpm | sed 's/^.*<a href="//' | sed 's/".*$//' | tail -1)
                wget http://www.nmon.net/packages/rpm/x64/nProbe/$latest
                alien -i $latest
            fi
            # END IF
            echo "Installing Maxmind GeoIP...."
            cd /tmp
            wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNumv6.dat.gz
            wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCityv6-beta/GeoLiteCityv6.dat.gz
            wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
            wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
            gunzip Geo*
            mkdir /usr/local/nprobe
            mv Geo*.dat /usr/local/nprobe/
            
            echo "nProbe Installation complete!"
            echo
            NPROBE='YES'
            ;;
        N|n|*)
            echo "Skipping nProbe Installation...."
            ;;
    esac

echo "## Would you like to install a local ELK? [Y/n]: "
    read  setELK
    case $setELK in
        Y|y)
            echo "Installing ELK...."
            ################################## ELK #################################
            echo 'Install Pre-Reqs and EL from elasticsearch repository'
            cd /usr/src
            wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
            echo 'deb http://packages.elasticsearch.org/elasticsearch/1.0/debian stable main' > /etc/apt/sources.list.d/elk.list
            echo 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main' >> /etc/apt/sources.list.d/elk.list
            apt-get update
            apt-get install elasticsearch logstash
            sudo update-rc.d elasticsearch defaults 95 10
            echo 'Configuring Elasticsearch'
            # sed -i '$a\cluster.name: elk' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\node.name: "elastic-master"' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\node.master: true' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\node.data: true' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\path.data: /var/data/elasticsearch' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\path.work: /var/data/elasticsearch/tmp' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\path.logs: /var/log/elasticsearch' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\index.number_of_shards: 1' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\index.number_of_replicas: 0' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\discovery.zen.ping.multicast.enabled: false' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\discovery.zen.ping.unicast.hosts: ["127.0.0.1:[9300-9400]"]' /etc/elasticsearch/elasticsearch.yml
            # sed -i '$a\bootstrap.mlockall: true' /etc/elasticsearch/elasticsearch.yml
            echo 'Create grok pattern folder'
            mkdir -p /etc/logstash/patterns
            cd /tmp
            git clone https://github.com/logstash/logstash
            cp logstash/patterns/* /etc/logstash/patterns/
            rm -rf logstash
            echo 'Remember to set you patterns_dir to "/etc/logstash/patterns" (i.e. patterns_dir => "/etc/logstash/patterns")'
            ################################# Kibana ################################
            echo 'Installing the Kibana frontend...'
            cd /usr/src
            # We use the Packetbeat fork in this version
            git clone https://github.com/packetbeat/kibana.git kibana
            mkdir /var/www/kibana
            mv kibana/src/* /var/www/kibana
            ############################# nprobe ELK ################################
            echo 'Configuring nProbe ELK...'
            cd $CWD
            cp logstash/conf.d/* /etc/logstash/conf.d/
            
            
            echo 'Restarting ELK..'
            service logstash restart
            service elasticsearch restart
            
            # Let's give it a sec to start
            echo "Waiting for services to start... "
            sleep 20
            
            echo "Installing custom Kibana Dashboards..."
            cd $CWD
            ./dashload.sh
            
            # All Done
            localip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
            echo "ELK Installation complete!"
            echo
            echo -e "Start nprobe and connect to http://$localip/kibana/#/dashboard/elasticsearch/Logstash%20Search"

            ;;
        N|n|*)
            echo "Skipping ELK Installation...."
            if [ "$NPROBE" == "Y" ]; then
                echo "* To install the nprobe template, copy logstash/conf.d/nprobe.conf to your Logstash(es)."
                echo "* To install the nProbe dashboards to your own Kibana use: ./dashload.sh {ELK_IP_ADDRESS}"
                echo
            fi
            ;;
    esac
echo "## All Done! Exiting..."
exit 0;
