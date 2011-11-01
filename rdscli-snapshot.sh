#!/bin/sh

## Configuration 
export JAVA_HOME=
export AWS_RDS_HOME=
export PATH=
export EC2_REGION=
export AWS_CREDENTIAL_FILE=

DBINSTANCE= 
TODAY=`date +\%Y\%m\%d`
COUNT=0
GENERATION=5
LOG=
TRANS_ADDRESS=

## start backup
echo  "start backup" > $LOG
echo  `date +\%Y\%m\%d` >> $LOG

## Create snapshot
rds-create-db-snapshot -i $DBINSTANCE -s backup-$DBNAME$TODAY
CREATE_CHECK=$?

## Delete snapshot
for i in `rds-describe-db-snapshots | cut -f3 -d ' ' | sort -r`
do
    if [ $COUNT -ge $GENERATION ];then
        echo "DELETE:$i"
        rds-delete-db-snapshot $i -f
    fi
    COUNT=`expr $COUNT + 1`
done
DELETE_CHECK=$?

## Send backuplog
rds-describe-db-snapshots |grep -e $DBINSTANCE >> $LOG
if [ $CREATE_CHECK = 0 -a $DELETE_CHECK = 0 ]
then
    echo "Backup Succeeded" >> $LOG
    cat $LOG | mail -s "Backup Suceeded" $TRANS_ADDRESS
else
    echo "Backup Failed" >> $LOG
    cat $LOG | mail -s "Backup Failed" $TRANS_ADDRESS
fi
