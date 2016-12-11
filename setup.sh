#!/bin/bash
if [ $# -ne 1 ]; then
    echo Usage: $0 yourdomain
    exit 1
fi

#Install Python and clone mobodoa installer
sudo apt-add-repository -y ppa:duplicity-team/ppa
sudo add-apt-repository -y ppa:chris-lea/python-boto
sudo apt-get update
sudo apt-get install -y build-essential python-pip python-rrdtool python-mysqldb python-dev libcairo2-dev ibpango1.0-dev librrd-dev libxml2-dev libxslt-dev zlib1g-dev duplicity python-boto mailutils ufw
git clone https://github.com/modoboa/modoboa-installer

#Setup Variables
domain=$1
mysql_password=`openssl rand -base64 32`
modoboa_password=`openssl rand -base64 32`
amavis_password=`openssl rand -base64 32`
spamassassin_password=`openssl rand -base64 32`
webmail_password=`openssl rand -base64 32`
webmail_user=`date +%s | sha256sum | base64 | head -c 12 ; echo`
email="admin@$domain"
gpg_pass=`openssl rand -base64 32`

#Chekc if running on OSX or Linux
case "$OSTYPE" in
  darwin*)  tempfile=".bak" ;; 
  *)        tempfile="" ;;
esac


#Place files in proper directories
mkdir local
#mkdir modoboa-installer
cp conf/installer.cfg modoboa-installer/installer.cfg
cp conf/backup.ini local/backup.ini
cp conf/aws.ini local/aws.ini
cp conf/tasks local/tasks
#cp gpg-settings.txt backup/gpg-settings.txt

#Customize backup settings
sed -i $tempfile 's|mysql_password|'$mysql_password'|g' local/backup.ini
sed -i $tempfile 's|modoboa_password|'$modoboa_password'|g' local/backup.ini
sed -i $tempfile 's|spamassassin_password|'$spamassassin_password'|g' local/backup.ini
sed -i $tempfile 's|amavis_password|'$amavis_password'|g' local/backup.ini
sed -i $tempfile 's|mydomain|'$domain'|g' local/backup.ini
sed -i $tempfile 's|admin_email|'$email'|g' local/backup.ini
sed -i $tempfile 's|webmail_password|'$webmail_password'|g' local/backup.ini
sed -i $tempfile 's|webmail_user|'$webmail_user'|g' local/backup.ini
sed -i $tempfile 's|backup_user|'$SUDO_USER'|g' local/backup.ini
sed -i $tempfile 's|backup_user|'$SUDO_USER'|g' local/tasks

#Customize modoboa settings
sed -i $tempfile 's|mysql_password|'$mysql_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|modoboa_password|'$modoboa_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|amavis_password|'$amavis_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|spamassassin_password|'$spamassassin_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|mydomain|'$domain'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|admin_email|'$email'|g' modoboa-installer/installer.cfg

#Generate GPG key and export passphrase
echo $gpg_pass > local/password.txt
rm -f local/*.bak modoboa-installer/*.bak

#Install modoboa
current=`pwd`
cd modoboa-installer
yes | sudo ./run.py $domain

cd $current
git clone https://github.com/jsarenik/spf-tools
git clone https://github.com/stevejenkins/postwhite
cp postwhite/example_whitelist.cidr /etc/postfix/postscreen_spf_whitelist.cidr
touch /etc/postfix/postscreen_spf_blacklist.cidr

mv spf-tools /usr/local/bin/
mv postwhite /usr/local/bin/
cp local/tasks /etc/cron.d/maintenance


#`cat conf/postfix.cf >> /etc/postfix/main.cf`
#cp conf/dovecot.conf /etc/dovecot/local.conf

./firewall.sh