#!/bin/bash
if [ $# -ne 1 ]; then
    echo Usage: $0 yourdomain
    exit 1
fi

domain=$1

sudo apt-get install -y python-pip python-rrdtool python-mysqldb python-dev libcairo2-dev ibpango1.0-dev librrd-dev libxml2-dev libxslt-dev zlib1g-dev
git clone https://github.com/modoboa/modoboa-installer
mv installer.cfg modoboa-installer/installer.cfg
cd modoboa-installer

sudo sed -i 's|mysql_password|'`openssl rand -base64 32`'|g' installer.cfg
sudo sed -i 's|modoboa_password|'`openssl rand -base64 32`'|g' installer.cfg
sudo sed -i 's|spam_assassin_password|'`openssl rand -base64 32`'|g' installer.cfg
sudo sed -i 's|mydomain|'$domain'|g' installer.cfg
sudo sed -i 's|mydomain|'$domain'|g' installer.cfg

sudo ./run.py $domain