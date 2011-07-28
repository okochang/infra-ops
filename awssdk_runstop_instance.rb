# -*- coding: utf-8 -*-

# aws-sdk for rubyを使用したEC2インスタンス起動スクリプト
# 引数に指定する値はリージョンURL、インスタンスID、固定IPとなります
# インスタンスのステータスを判定して起動もしくは停止をします

require 'rubygems'
require 'aws-sdk'

## アクセスIDとシークレットアクセスキーを指定します。
ACCESS_KEY = 'SET_UP_YOUR_ACCESS_KEY'
SECRET_KEY = 'SET_UP_YOUR_SECRET_KEY'

## 引数チェック
unless ARGV.size == 3
  puts 'Usage: awssdk_runstop_instance.rb <aws_region_url> <instance-id> <elastic-ip>'
  exit 0
end

## 引数から起動、停止するインスタンスの設定を行います。
aws_region = ARGV[0]
instance_id = ARGV[1]
elasticip = ARGV[2]

## EC2インターフェースを作成するために認証を行います
AWS.config(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY, :ec2_endpoint => aws_region)
ec2 = AWS::EC2.new

## 引数から対象インスタンスとElasticIPを設定します
target_instance = ec2.instances[instance_id]

## 対象インスタンスのステータスを確認します
instance_status = target_instance.status

## ステータスが停止中ならばインスタンスを起動してEIPを割り当てます
if instance_status == :stopped then
  target_instance.start
  sleep 1 while target_instance.status == :pending
  target_instance.associate_elastic_ip(elasticip)
## ステータスが起動中ならばインスタンスを一時停止します
elsif instance_status == :running then
  target_instance.stop
end

