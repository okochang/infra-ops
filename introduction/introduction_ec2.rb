# -*- coding: utf-8 -*- 
## EC2インスタスを起動するまでの流れで、スクリプトではないので注意して下さい
require 'aws-sdk'
ACCESS_KEY = 'set your access key id'
SECRET_KEY = 'set your secret key'
EC2_REGION = 'ec2.ap-southeast-1.amazonaws.com'

ec2 = AWS::EC2.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :ec2_endpoint => EC2_REGION
).client

## 設定
ip_address = '0.0.0.0/0'
security_group_name = 'okochang-security-group'
description = Time.now.strftime("%Y-%m-%d")
ssh_key_name = 'mba-yanase'
public_key = Base64.encode64('ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGm9VzTxxxxxxxxxxxxxM38MlxT65G0AoMxxxxAi1Ccm75kTmXsi2TdbdrsxxxxxxxxxxxxxxxxxxxxxxKCwhg8N1k1BIyRet2gwZFyXXYsFrdFxxxxxxxxxxxxxxxxxxwQofXoL/TuTRQC okochang')
ami_id = 'ami-ba7538e8'
instance_type = 't1.micro'
zone = 'ap-southeast-1a'

## セキュリティグループを作成
ec2.create_security_group(:group_name => security_group_name, :description => description)

## セキュリティグループのルールを追加
ec2.authorize_security_group_ingress(:group_name => security_group_name, :ip_permissions => [{:ip_protocol => 'tcp', :from_port => 22, :to_port => 22, :ip_ranges => [:cidr_ip => ip_address]}, {:ip_protocol => 'icmp', :from_port => -1, :to_port => -1, :ip_ranges => [:cidr_ip => ip_address]}])

## SSH公開鍵をインポート
ec2.import_key_pair(:key_name => ssh_key_name, :public_key_material => public_key)

## EC2インスタンスを起動します
ec2.run_instances(
:image_id => ami_id,
:min_count => 1,
:max_count => 1,
:key_name => ssh_key_name,
:security_groups => [security_group_name],
:instance_type => instance_type,
:placement => {:availability_zone => zone},
:disable_api_termination => false
)

## 起動したインスタンスを確認
ec2.describe_instances[:instance_index]

## システムステータスとインスタンスステータスを確認
ec2.describe_instance_status[:instance_status_set][0][:system_status]
ec2.describe_instance_status[:instance_status_set][0][:instance_status]

## EC2インスタンスのイベントを確認
ec2.describe_instance_status[:instance_status_set][0][:events_set]

## 再起動
ec2.reboot_instances(:instance_ids => ["i-f5b721a2"])

## 必要なくなったら削除
ec2.terminate_instances(:instance_ids => ["i-f5b721a2"])
