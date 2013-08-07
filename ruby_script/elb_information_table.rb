# -*- coding: utf-8 -*-
require 'aws-sdk'

access_key = 'set your access key'
secret_key = 'set your secret key'
elb_region = 'elasticloadbalancing.ap-northeast-1.amazonaws.com'

elb = AWS::ELB.new(
  :access_key_id => access_key,
  :secret_access_key => secret_key,
  :elb_endpoint => elb_region
).client

## 起動しているELBの情報を取得します。
elbs = elb.describe_load_balancers[:load_balancer_descriptions]

## ELBテーブルのタイトルを出力します
puts "|名前|接続先|VPC ID|セキュリティグループ|AZ|ロードバランサポート|サーバーポート|h"

## 各ELBの情報でテーブル作成に必要な情報をそれぞれ出力します。
elbs.each do |lb|
  if lb[:vpc_id].nil?
    vpc_id = "N/A"
  else
    vpc_id = lb[:vpc_id]
  end
  if lb[:source_security_group]
    source_security_group = "N/A"
  else
    source_security_group[:source_security_group][:group_name]
  end
  name = lb[:load_balancer_name]
  dns_name = lb[:dns_name]
  az = lb[:availability_zones]
  lb_port = []
  lb[:listener_descriptions].each do |description|
    lb_port << description[:listener][:load_balancer_port]
  end
  instance_port = []
  lb[:listener_descriptions].each do |description|
    instance_port << description[:listener][:instance_port]
  end
  puts  "|" + name + "|" + dns_name + "|" + vpc_id + "|" + source_security_group + "|" + az.join(",") + "|" + lb_port.join(",") + "|" + instance_port.join(",") + "|"
end
