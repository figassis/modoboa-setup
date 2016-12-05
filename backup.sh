#!/bin/bash

source backup.ini
source aws.ini

# Export some ENV variables so you don't have to type anything
export AWS_ACCESS_KEY_ID=$KEY_ID
export AWS_SECRET_ACCESS_KEY=$SECRET_KEY

# The S3 destination followed by bucket name
DEST="s3://s3.amazonaws.com/$BUCKET"

# Your GPG key
GPG_KEY="backup/"$DOMAIN".pub"

HOST=`hostname`
DATE=`date +%Y-%m-%d`
TODAY=$(date +%d%m%Y)

#Create MySQL backups
mkdir ~/mysql_backup

mysqldump –lock-all-tables -u $MODOBOA_DB_USER -pMODOBOA_DB_PW $MODOBOA_DATABASE > "~/mysql_backup/$MODOBOA_DATABASE.sql"
mysqldump –lock-all-tables -u $SPAMASSASSINUSER -p$SPAMASSASSINPW $SPAMASSASSINDB > "~/mysql_backup/SPAMASSASSINDB.sql"
mysqldump –lock-all-tables -u $AMAVISDBUSER -p$AMAVISDBPW $AMAVISDB > "~/mysql_backup/$AMAVISDB.sql"

is_running=$(ps -ef | grep duplicity  | grep python | wc -l)

if [ ! -d /var/log/duplicity ];then
    mkdir -p /var/log/duplicity
fi

if [ ! -f $FULLBACKLOGFILE ]; then
    touch $FULLBACKLOGFILE
fi

if [ $is_running -eq 0 ]; then
    # Clear the old daily log file
    cat /dev/null > ${DAILYLOGFILE}

    # Trace function for logging, don't change this
    trace () {
            stamp=`date +%Y-%m-%d_%H:%M:%S`
            echo "$stamp: $*" >> ${DAILYLOGFILE}
    }

    # How long to keep backups for
    OLDER_THAN="1M"

    # The source of your backup
    SOURCE=/

    FULL=
    tail -1 ${FULLBACKLOGFILE} | grep ${TODAY} > /dev/null
    if [ $? -ne 0 -a $(date +%d) -eq 1 ]; then
            FULL=full
    fi;

    trace "Backup for local filesystem started"

    trace "... removing old backups"

    duplicity remove-older-than ${OLDER_THAN} ${DEST} >> ${DAILYLOGFILE} 2>&1

    trace "... backing up filesystem"

    duplicity \
        ${FULL} \
        --encrypt-key=${GPG_KEY} \
        --sign-key=${GPG_KEY} \
        --include=~/mysql_backup \
        --include=$MODOBOA_DIR \
        --include=$NGINX_DIR \
        --include=$RAZOR_DIR \
        --include=$POSTFIX \
        --include=$DOVECOT_DIR \
        --include=$SPAMASSASSIN_DIR \
        --exclude=/** \
        ${SOURCE} ${DEST} >> ${DAILYLOGFILE} 2>&1

    trace "Backup for local filesystem complete"
    trace "------------------------------------"

    # Send the daily log file by email
    #cat "$DAILYLOGFILE" | mail -s "Duplicity Backup Log for $HOST - $DATE" $MAILADDR
    BACKUPSTATUS=`cat "$DAILYLOGFILE" | grep Errors | awk '{ print $2 }'`
    if [ "$BACKUPSTATUS" != "0" ]; then
	   cat "$DAILYLOGFILE" | mail -s "Duplicity Backup Log for $HOST - $DATE" $MAILADDR
    elif [ "$FULL" = "full" ]; then
        echo "$(date +%d%m%Y_%T) Full Back Done" >> $FULLBACKLOGFILE
    fi

    # Append the daily log file to the main log file
    cat "$DAILYLOGFILE" >> $LOGFILE

    # Reset the ENV variables. Don't need them sitting around
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    
    #Remove temporary mysql dumps
    rm -rf ~/mysql_backup
fi