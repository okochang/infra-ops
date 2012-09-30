# -*- coding: utf-8 -*-

## 必要なライブラリ
require 'right_aws'

## 引数チェック
unless ARGV.size == 1 then
  puts "引数が正しく設定されていません"
  exit 1
end

## 各種設定項目
t = Time.now
ACCESS_KEY = 'SET_YOUR_ACCESS_KEY'
SECRET_KEY = 'SET_YOUR_SECRET_KEY'
REGION = 'ec2.ap-northeast-1.amazonaws.com'
instance_name = ARGV[0]
ami_name = "backup-ami-#{t.strftime('%Y%m%d%H%M')}"
ami_description = "system fault backup"

## AWSの認証を行います
ec2 = RightAws::Ec2.new(ACCESS_KEY, SECRET_KEY, :server => REGION)

## タグの名前からターゲットとなるインスタンスIDを取得します
target_instance = []
ec2.describe_tags.each do |tag|
  if instance_name == tag[:value] and /^i-./ === tag[:resource_id]
    target_instance << tag[:resource_id]
  end
end

## ターゲットのインスタンスが正しいものかチェックします
unless target_instance.size == 1 then
  puts "指定されたNameタグないか、複数存在しています"
  exit 1
end

## インスタンスIDからターゲットの詳細情報を取得します
target_instance_property = ec2.describe_instances(target_instance)[0]

## バックアップ用のAMIを作成します
backup_ami = ec2.create_image(target_instance_property[:aws_instance_id], \
:description => ami_description, \
:no_reboot => true, \
:name => ami_name)

## バックアップ用に作成したAMIのステータスをチェックします
until ec2.describe_images(backup_ami)[0][:aws_state] == "available"
  puts "バックアップ用のAMIを作成中です"
  sleep 10
end

## インスタンスをSTOPします
ec2.stop_instances(target_instance_property[:aws_instance_id])

## インスタンスの状態をチェックし、停止状態になったら起動とEIPの再割り当てをします
## 15分後に変化がなければ、新しいインスタンス起動の処理に移ります
15.times do
  if ec2.describe_instances(target_instance_property[:aws_instance_id])[0][:aws_state] == "stopped"
    ec2.start_instances(target_instance_property[:aws_instance_id])
    until ec2.describe_instances(target_instance_property[:aws_instance_id])[0][:aws_state] == "running"
      puts "ターゲットインスタンスを起動中です"
      sleep 10
    end
    ec2.associate_address(target_instance_property[:aws_instance_id], target_instance_property[:ip_address])
    puts "ターゲットインスタンスの起動が完了しました"
      exit 0
  else
    puts "ターゲットインスタンスを停止中です"
    sleep 60
  end
end

## 先ほど作成したバックアップAMIから新しいインスタンスを起動します
## 停止前に割り当てられていたEIPを新しく起動したEIPに割り当てます
new_instance_property = ec2.run_instances(backup_ami, 1, 1, \
target_instance_property[:aws_groups], \
target_instance_property[:ssh_key_name], \
target_instance_property[:aws_availability_zone], \
'', \
target_instance_property[:aws_instance_type])
until ec2.describe_instances(new_instance_property[0][:aws_instance_id])[0][:aws_state] == "running"
  puts "新しいインスタンスを起動中です"
  sleep 10
end
ec2.associate_address(new_instance_property[0][:aws_instance_id], target_instance_property[:ip_address])
puts "新しいインスタンスの起動が完了しました"
exit 0
