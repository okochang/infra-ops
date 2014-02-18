#!/bin/sh -x
SECURITY_GROUP1=$1
SECURITY_GROUP2=$2

## Print the Security Group contents
ec2-describe-group --filter "group-name=${SECURITY_GROUP1}" | sort -k6 -k10 | awk '{$3="";print}' > tempfile1.txt
ec2-describe-group --filter "group-name=${SECURITY_GROUP2}" | sort -k6 -k10 | awk '{$3="";print}' > tempfile2.txt

## Check the diff
diff -u tempfile1.txt tempfile2.txt

## Delete tempfiles
rm -rf tempfile1.txt tempfile2.txt