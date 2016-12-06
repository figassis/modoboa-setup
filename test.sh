#!/bin/bash
if [ $# -ne 1 ]; then
    echo Usage: $0 yourdomain
    exit 1
fi

clear
#Setup Variables
domain=$1
mysql_password="MTC5fnkzvJTZGYKwa2qvbY0QkP+dDlxopWDBEJnZc1A="
modoboa_password="6l3ZSYZoHauabp30rJae2ucSLRS9VLoJiuJCshaidTo="
amavis_password="amavis_password"
spamassassin_password="password"
email="admin@$domain"
gpg_pass=`openssl rand -base64 32`

#Chekc if running on OSX or Linux
case "$OSTYPE" in
  darwin*)  tempfile=".bak" ;; 
  *)        tempfile="" ;;
esac


#Place files in proper directories
rm -rf modoboa-installer backup "$domain.*"
mkdir backup modoboa-installer
cp installer.cfg modoboa-installer/installer.cfg
cp backup.ini backup/backup.ini
cp gpg-settings.txt backup/gpg-settings.txt

#Customize unnatended GPG Key generation
PASSWORD="$gpg_pass" perl -i -p -e 's/very_long_passphrase/$ENV{PASSWORD}/g' backup/gpg-settings.txt > /dev/null 2>&1
sed -i $tempfile 's|admin_email|'$email'|g' backup/gpg-settings.txt
sed -i $tempfile 's|admin_name|'$domain'|g' backup/gpg-settings.txt
sed -i $tempfile 's|mydomain|'$domain'|g' backup/gpg-settings.txt

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
sed -i $tempfile 's|cert_email|'$email'|g' modoboa-installer/installer.cfg

#Export GPG passphrase
echo $gpg_pass > backup/password.txt

#Generate GPG key
rm -rf gpg
mkdir -m 0700 gpg
#touch gpg/gpg.conf
#chmod 600 gpg/gpg.conf
#tail -n +4 /usr/share/gnupg2/gpg-conf.skel > gpg/gpg.conf
#touch gpg/"$domain.sec" gpg/"$domain.pub"
gpg --homedir gpg --list-secret-keys

#gpg --no-tty --no-permission-warning --homedir gpg --batch --gen-key backup/gpg-settings.txt 2>&1
sudo rngd -r /dev/urandom
gpg --no-tty --no-permission-warning --no-random-seed-file  --homedir ./gpg --batch --gen-key backup/gpg-settings.txt
echo "Result: $?"
#echo "Files:"
ls gpg
#cat "gpg/$domain.pub"
#cat "gpg/$domain.sec"
#exit 1

#List keys
gpg --homedir ./gpg --no-default-keyring --secret-keyring "./gpg/$domain.sec" --keyring "./gpg/$domain.pub" --list-secret-keys
exit 1

# Export public key
gpg --homedir gpg --export -a $email > "$domain.pub"
gpg --homedir gpg --export-secret-key -a $email > "$domain.sec"
echo "Content of public key:"
cat "$domain.pub"
#rm -rf gpg
#gpg2 --verbose --batch --gen-key backup/gpg-settings.txt
#gpg2 --no-default-keyring --secret-keyring "$domain.sec" --keyring "$domain.pub" --list-secret-keys


exit 1
mv "$domain.pub" backup/"$domain.pub"
mv "$domain.sec" backup/"$domain.sec"
rm -f backup/*.bak modoboa-installer/*.bak
