# -*- coding: utf-8 -*-
require 'aws-sdk'

ACCESS_KEY ='set your access key id'
SECRET_KEY = 'set your secret key'
REGION = 'rds.ap-northeast-1.amazonaws.com'
rds_information_array = []
 
rds = AWS::RDS.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :rds_endpoint => REGION
).client


## テーブルに出力するDBインスタンスの項目を出力します
puts "|DBインスタンス名|DBインスタンスタイプ|ディスク容量|接続先|ポート番号|DBエンジン|DBバージョン|Multi-AZ|パラメータグループ|セキュリティグループ|バックアップウィンドウ|メンテナンスウィンドウ|h"

## DBインスタンスの一覧を取得します
db_instances = rds.describe_db_instances[:db_instances]

## 各DBインスタンスの情報をまとめます
db_instances.each do |db_instance|
  rds_information_array << [db_instance[:db_instance_identifier], db_instance[:db_instance_class], db_instance[:allocated_storage], db_instance[:endpoint][:address], db_instance[:endpoint][:port], db_instance[:engine], db_instance[:engine_version], db_instance[:multi_az], db_instance[:db_parameter_groups][0][:db_parameter_group_name], db_instance[:db_security_groups][0][:db_security_group_name], db_instance[:preferred_backup_window], db_instance[:preferred_maintenance_window]]
end

## 配列中のDBインスタンスをDBインスタンス名でソートします
rds_information_array = rds_information_array.sort

## DBインスタンスの情報を出力します
rds_information_array.each do |data|
  puts "|" + data[0] + "|" + data[1] + "|" + data[2].to_s + "|" + data[3] + "|" + data[4].to_s + "|" + data[5] + "|" + data[6] + "|" + data[7].to_s + "|" + data[8] + "|" + data[9] + "|" + data[10] + "|" + data[11] + "|"
end
exit 0

