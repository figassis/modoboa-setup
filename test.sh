#!/bin/bash
if [ $# -ne 1 ]; then
    echo Usage: $0 yourdomain
    exit 1
fi

 #Setup Variables
domain=$1
mysql_password=`openssl rand -base64 32`
modoboa_password=`openssl rand -base64 32`
amavis_password=`openssl rand -base64 32`
spamassassin_password=`openssl rand -base64 32`
email="admin@$domain"
gpg_pass=`openssl rand -base64 32`

#Chekc if running on OSX or Linux
case "$OSTYPE" in
  darwin*)  tempfile=".bak" ;; 
  *)        tempfile="" ;;
esac

#echo $gpg_pass
#exit 1
#Place files in proper directories
rm -rf modoboa-installer backup
mkdir backup modoboa-installer
cp installer.cfg modoboa-installer/installer.cfg
cp backup.ini backup/backup.ini
cp gpg-settings.txt backup/gpg-settings.txt

#Customize unnatended GPG Key generation
PASSWORD="$gpg_pass" perl -i -p -e 's/very_long_passphrase/$ENV{PASSWORD}/g' backup/gpg-settings.txt > /dev/null 2>&1

#sed -i 's|very_long_passphrase|'$gpg_pass'|g' backup/gpg-settings.txt
sed -i $tempfile 's|admin_email|'$email'|g' backup/gpg-settings.txt
sed -i $tempfile 's|admin_name|'$domain'|g' backup/gpg-settings.txt
sed -i $tempfile 's|mydomain|'$domain'|g' backup/gpg-settings.txt
#rm -rf modoboa-installer backup


#Customize backup settings
sed -i $tempfile 's|mysql_password|'$mysql_password'|g' backup/backup.ini
sed -i $tempfile 's|modoboa_password|'$modoboa_password'|g' backup/backup.ini
sed -i $tempfile 's|spamassassin_password|'$spamassassin_password'|g' backup/backup.ini
sed -i $tempfile 's|amavis_password|'$amavis_password'|g' backup/backup.ini
sed -i $tempfile 's|mydomain|'$domain'|g' backup/backup.ini

#Customize modoboa settings
sed -i $tempfile 's|mysql_password|'$mysql_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|modoboa_password|'$modoboa_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|amavis_password|'$amavis_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|spamassassin_password|'$spamassassin_password'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|mydomain|'$domain'|g' modoboa-installer/installer.cfg
sed -i $tempfile 's|cert_email|'$email'|g' modoboa-installer/installer.cfg

#Generate GPG key and export passphrase
echo $gpg_pass > backup/password.txt
gpg2 --batch --gen-key backup/gpg-settings.txt
mv "$domain.pub" backup/"$domain.pub"
mv "$domain.sec" backup/"$domain.sec"
rm -f backup/*.bak modoboa-installer/*.bak