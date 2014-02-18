#!/bin/sh -x

SRC_GROUP=$1
DST_GROUP=$2
PROTOCOL=$3
FROM_PORT=$4
TO_PORT=$5
TARGET_TYPE=\"$6\"

## Check protocol
case $PROTOCOL in
    "tcp" | "udp")
        echo "OK running script" ;;
    "icmp")
        echo "Hmm sorry unsupported this script" ;;
    *)
        echo "Unknown protocol"    
esac

## Check destination group id
GROUP_ID=`ec2-describe-group --filter "group-name=${DST_GROUP}" | awk 'NR==1 {print $2}'`

## Check src contents
RULES=`ec2-describe-group --filter "group-name=${SRC_GROUP}" | \
awk '{if ($6 == '$FROM_PORT' && $7 == '$TO_PORT' && $9 == '$TARGET_TYPE') print $10}' | \
tr '\n' " " | \
sed -e  "s/.$//" | \
sed -e "s/ / -s /g"`

## Copy contents
case $TARGET_TYPE in
    \"CIDR\")
        ec2-authorize $GROUP_ID --protocol $PROTOCOL -p $FROM_PORT-$TO_PORT -s $RULES ;;
    \"USER\")
        ec2-authorize $GROUP_ID --protocol $PROTOCOL -p $FROM_PORT-$TO_PORT -o $RULES ;;
    *)
    echo error
esac