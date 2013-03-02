# -*- coding: utf-8 -*-

require 'aws-sdk'

ACCESS_KEY = 'set your access key id'
SECRET_KEY = 'set your secret key'
REGION = 'ec2.ap-northeast-1.amazonaws.com'

ec2 = AWS::EC2.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :ec2_endpoint => REGION
).client

## リージョン内のインスタスとボリュームの情報を取得する
instances_information = ec2.describe_instances[:instance_index]
volumes_information = ec2.describe_volumes[:volume_index]

## インスタンス情報格納用の配列を作成する
instances_information_array = []

## インスタンス情報でテーブル化する項目を出力する
puts "|名前|インスタンスID|インスタンスタイプ|ローカルIPアドレス|パブリックIPアドレス|ルートボリュームサイズ|h"

## インスタンスの情報から必要なものを取得して整理する
instances_information.each_value do |value|
  ## インスタンスに紐付いたタグからNameタグを判定する
  name_tag = []
  tags = value[:tag_set]
  tags.each do |tag|
    if tag[:key] == "Name"
      name_tag << tag[:value]
    end
    if name_tag[0] == nil
      name_tag[0] = " "
    end
  end
  ## ルートボリュームの種類とEBSだった場合のサイズを判定する
  volumes = value[:block_device_mapping]
  if volumes.empty?
    root_volume_id = "instance-store"
  else
    volumes.each do |volume_data|
      if volume_data[:device_name] == "/dev/sda1" || volume_data[:device_name] == "/dev/sda"
        root_volume_id = volume_data[:ebs][:volume_id]
      end
    end
  end
  ## インスタンスのPrivate IPが付与されているか判定する
  if value[:private_ip_address].nil?
    private_ip = "N/A"
  else
    private_ip = value[:private_ip_address]
  end  
  ## インスタンスのPublic IPが付与されているか判定する
  if value[:ip_address].nil?
    public_ip = "N/A"
  else
    public_ip = value[:ip_address]
  end
  ## インスタンス情報格納用配列の最後にインスタンス情報を格納する
  if root_volume_id == "instance-store"
    instances_information_array << [name_tag, value[:instance_id], value[:instance_type], private_ip, public_ip, root_volume_id]
  else
    instances_information_array << [name_tag, value[:instance_id], value[:instance_type], private_ip, public_ip, volumes_information[root_volume_id][:size]]
  end
end

## インスタンス情報格納用配列をNameタグでソートする
instances_information_array = instances_information_array.sort

## インスタンス情報を出力する
instances_information_array.each do |data|
  puts "|" + data[0][0] + "|" + data[1] + "|" + data[2] + "|" + data[3] + "|" + data[4] + "|" + data[5].to_s + "|"
end
exit 0
