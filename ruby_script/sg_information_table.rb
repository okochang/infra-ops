# -*- coding: utf-8 -*-
require 'aws-sdk'

ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'
REGION = 'ec2.ap-northeast-1.amazonaws.com'

ec2 = AWS::EC2.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :ec2_endpoint => REGION
).client

security_groups = ec2.describe_security_groups[:security_group_info]

security_groups.each do |security_group|
  puts "|グループ 名|グループ ID|VPC ID|h"
  if security_group[:group_name].nil?
    group_name = "N/A"
  else
    group_name = security_group[:group_name]
  end

  if security_group[:group_id].nil?
    group_id = "N/A"
  else
    group_id = security_group[:group_id] 
  end

  if security_group[:vpc_id].nil?
    vpc_id = "N/A"
  else
    vpc_id = security_group[:vpc_id]
  end

  puts "|" + group_name + "|" + group_id + "|" + vpc_id + "|"
  puts "\n"
  puts "|\'\'プロトコル\'\'|\'\'ポート番号\'\'|\'\'接続元\'\'|"
  security_group[:ip_permissions].each do |ip_permission|
    protocol = ip_permission[:ip_protocol]
    if ip_permission[:from_port].nil?
      port = "ALL Traffic"
    else
      port = ip_permission[:from_port].to_s + "〜" + ip_permission[:to_port].to_s      
    if ip_permission[:groups].empty?
      source = []
      ip_permission[:ip_ranges].each do |ip|
        source << ip[:cidr_ip]
      end
    end
    if ip_permission[:ip_ranges].empty?
      source = []
      ip_permission[:groups].each do |group|
        source << group[:group_id]
      end
    end
    puts "|" + protocol + "|" + port + "|" + source.join(",") + "|"
  end
  end
  puts "\n"
end      

