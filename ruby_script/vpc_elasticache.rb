# -*- coding: utf-8 -*-
require 'aws-sdk'

ACCESS_KEY = "AKIAJ4PGREBSSJBYSYKQ"
SECRET_KEY = "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"
REGION = 'elasticache.ap-northeast-1.amazonaws.com'

ec = AWS::ElastiCache.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :ec2_endpoint => REGION
).client
