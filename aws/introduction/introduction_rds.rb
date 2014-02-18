# -*- coding: utf-8 -*-
require 'aws-sdk'

## 設定
access_key = 'AKIAJ4PGREBSSJBYSYKQ'
secret_key = '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'
rds_region = 'rds.ap-southeast-1.amazonaws.com'

rds = AWS::RDS.new(
:access_key_id => access_key,
:secret_access_key => secret_key,
:auto_scaling_endpoint => rds_region
).client

## 
