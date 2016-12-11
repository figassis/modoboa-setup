#!/bin/bash

if [ $# -ne 1 ]; then
    echo Usage: $0 ip_address
    exit 1
fi
IP=$1
source local/backup.ini

mysql -u$DBROOT -p$DBROOT_PASS -e "CREATE USER ${WEBMAIL_DB_USER}@${IP} IDENTIFIED BY '${WEBMAIL_DB_PW}';"
mysql -u$DBROOT -p$DBROOT_PASS -e "GRANT ALL PRIVILEGES ON ${MODOBOA_DATABASE}.core_user TO '${WEBMAIL_DB_USER}'@'${IP}';"
mysql -u$DBROOT -p$DBROOT_PASS -e "FLUSH PRIVILEGES;"