# -*- coding: utf-8 -*-
require 'net/http'
require 'aws-sdk'

ec2_region = 'ec2.' + Net::HTTP.get('169.254.169.254', '/latest/meta-data/placement/availability-zone').chop + '.amazonaws.com'

@ec2 = AWS::EC2.new(
  :ec2_endpoint => ec2_region
).client

2012-08-15T15:00:00


@ec2.describe_spot_price_history(:filters => [{:name => 'instance-type', :values => ['t1.micro']},{:name => 'availability-zone', :values => ['ap-northeast-1c']}])


スポットインスタンスリクエストの中からインスタンスIDがいるものをfilterする
