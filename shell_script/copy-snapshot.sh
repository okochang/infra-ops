#!/bin/sh -x

## setup
TODAY=`date +\%Y\%m\%d`
INSTANCE_NAME="set your instance name"
EBS_VOLUME="set your ebs volume id"
EBS_GENERATION=5
SRC_REGION="ap-northeast-1"
DST_REGION="ap-southeast-1"
TAG="set your management tag"

export export JAVA_HOME="set your java home"
export EC2_HOME="set your ec2-api-tools install dir"
export PATH=$PATH:$EC2_HOME/bin:$JAVA_HOME/bin
export AWS_ACCESS_KEY="set your access key"
export AWS_SECRET_KEY="set your secret key"

## create snapshot
NEW_SNAPSHOT=`ec2-create-snapshot --region $SRC_REGION $EBS_VOLUME -d $TAG-$INSTANCE_NAME-$TODAY \
| awk '{print $2}'`

## sleep
sleep 300

## copy snapshot to destination region
ec2-copy-snapshot --region $DST_REGION -s $NEW_SNAPSHOT -r $SRC_REGION -d $TAG-$INSTANCE_NAME-$TODAY

## sleep
sleep 300

## source region snapshots
SRC_SNAPSHOTS=`ec2-describe-snapshots --region $SRC_REGION --filter "description=${TAG}*" \
| sort -k5 -r | awk '{print $2}'`

## destination region snapshots
DST_SNAPSHOTS=`ec2-describe-snapshots --region $DST_REGION --filter "description=${TAG}*" \
| sort -k5 -r | awk '{print $2}'`

## delete source region snapshot
COUNT=1
for SNAPSHOT in $SRC_SNAPSHOTS ; do
        if [ $COUNT -le $EBS_GENERATION ] ; then
                echo $SNAPSHOT "keep snapshot"
        else
                ec2-delete-snapshot \
                --region $SRC_REGION \
                $SNAPSHOT
                echo $SNAPSHOT "delete snapshot"
        fi
        COUNT=`expr $COUNT + 1`
done
## delete destination region snapshot
COUNT=1
for SNAPSHOT in $DST_SNAPSHOTS ; do
        if [ $COUNT -le $EBS_GENERATION ] ; then
                echo $SNAPSHOT "keep snapshot"
        else
                ec2-delete-snapshot \
                --region $DST_REGION \
                $SNAPSHOT
                echo $SNAPSHOT "delete snapshot"
        fi
        COUNT=`expr $COUNT + 1`
done