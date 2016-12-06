#!/bin/bash
if [ $# -ne 1 ]; then
    echo Usage: $0 yourdomain
    exit 1
fi

#Install Python and clone mobodoa installer
sudo apt-add-repository -y ppa:duplicity-team/ppa
sudo add-apt-repository -y ppa:chris-lea/python-boto
sudo apt-get update
sudo apt-get install -y python-pip python-rrdtool python-mysqldb python-dev libcairo2-dev ibpango1.0-dev librrd-dev libxml2-dev libxslt-dev zlib1g-dev duplicity python-boto
git clone https://github.com/modoboa/modoboa-installer

#Setup Variables
domain=$1
mysql_password=`openssl rand -base64 32`
modoboa_password=`openssl rand -base64 32`
amavis_password=`openssl rand -base64 32`
spamassassin_password=`openssl rand -base64 32`
email="admin@$domain"
gpg_pass=`openssl rand -base64 2048`

#Chekc if running on OSX or Linux
case "$OSTYPE" in
  darwin*)  tempfile=".bak" ;; 
  *)        tempfile="" ;;
esac


#Place files in proper directories
#rm -rf modoboa-installer backup
mkdir backup
#mkdir modoboa-installer
cp installer.cfg modoboa-installer/installer.cfg
cp backup.ini backup/backup.ini
#cp gpg-settings.txt backup/gpg-settings.txt

#Customize backup settings
sed -i $tempfile 's|mysql_password|'$mysql_password'|g' backup/backup.ini
sed -i $tempfile 's|modoboa_password|'$modoboa_password'|g' backup/backup.ini
sed -i $tempfile 's|spamassassin_password|'$spamassassin_password'|g' backup/backup.ini
sed -i $tempfile 's|amavis_password|'$amavis_password'|g' backup/backup.ini
sed -i $tempfile 's|mydomain|'$domain'|g' backup/backup.ini
sed -i $tempfile 's|admin_email|'$email'|g' backup/backup.ini

#Customize modoboa settings
sed -i $tempfile 's|mysql_password|'$mysql_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|modoboa_password|'$modoboa_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|amavis_password|'$amavis_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|spamassassin_password|'$spamassassin_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|mydomain|'$domain'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|admin_email|'$email'|g' modoboa-installer/installer.cfg

#Generate GPG key and export passphrase
echo $gpg_pass > backup/password.txt
rm -f backup/*.bak modoboa-installer/*.bak

#Install modoboa
cd modoboa-installer
sudo ./run.py $domain