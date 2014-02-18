# -*- coding: utf-8 -*-

## 必要なライブラリ
require 'right_aws'

## 各種設定
src_group_id = ARGV[0]
dst_group_name = ARGV[1]
description = ARGV[2]
ACCESS_KEY = 'set your access key id'
SECRET_KEY = 'set your secret key'
REGION = 'ec2.ap-northeast-1.amazonaws.com'

## 引数のチェック
unless ARGV.size == 3 then
  puts "引数が正しく設定されていません"
  exit 1
end

## AWSへの認証を行います
ec2 = RightAws::Ec2.new(ACCESS_KEY, SECRET_KEY, :server => REGION)

## 移行元のセキュリティグループのVPC IDをチェックします
vpc_id = ec2.describe_security_groups(:filters => {'group-id' => src_group_id})[0][:vpc_id]

## 移行先となるセキュリティグループを作成します
if vpc_id.nil?
  dst_group_id = ec2.create_security_group(dst_group_name, description)[:group_id]
else
  dst_group_id = ec2.create_security_group(dst_group_name, description, :vpc_id => vpc_id)[:group_id]
  ec2.modify_security_group(:revoke, :egress, dst_group_id, :cidr_ips=>"0.0.0.0/0", :protocol=>"-1")
end

## 移行元のセキュリティグループに割り当てられたルールを取得します
rules = ec2.describe_security_groups(:filters => {'group-id' => src_group_id})[0][:aws_perms]

## 移行先のセキュリティグループにルールを適用します
for rule in rules
  if rule[:cidr_ips].nil?
    ec2.modify_security_group(
    :authorize,
    rule[:direction].to_sym,
    dst_group_id,
    :from_port => rule[:from_port],
    :to_port => rule[:to_port],
    :protocol => rule[:protocol],
    :direction => rule[:direction],
    :groups => {rule[:owner] => rule[:group_id]}
    )
  else
    ec2.modify_security_group(
    :authorize,
    rule[:direction].to_sym,
    dst_group_id,
    :from_port => rule[:from_port],
    :to_port => rule[:to_port],
    :protocol => rule[:protocol],
    :cidr_ip => rule[:cidr_ips]
    )
  end
end
exit 0
