# -*- coding: utf-8 -*- 
require 'net/http'
require 'aws-sdk'

instance_id = Net::HTTP.get('169.254.169.254', '/latest/meta-data/instance-id')
ec2_region = "ec2.#{Net::HTTP.get('169.254.169.254', '/latest/meta-data/placement/availability-zone').chop}.amazonaws.com"
image_name = "#{instance_id}-#{Time.now.strftime("%Y%m%d%H%M")}"
comment = "automatically generated image"
 
@ec2 = AWS::EC2.new(
  :ec2_endpoint => ec2_region
).client

## インスタンスの対象からタグを取得する
def check_tag_set(instance_id)
  tag_set = @ec2.describe_instances(instance_ids: ["#{instance_id}"])[:instance_index][instance_id][:tag_set]
end

## 取得したタグからバックアップの設定を確認します
def check_backup_config(instance_id)
  backup_config = Hash.new
  check_tag_set(instance_id).each do |tag|
    if tag[:key] == 'backup' && tag[:value] == 'on'
      backup_config[:flag] = true
    end
    if tag[:key] == 'generation'
      backup_config[:generation] = tag[:value]
    end
  end
  return backup_config
end

## バックアップの世代から多すぎるものを特定する
def check_delete_images(instance_id)
  backup_config = check_backup_config(instance_id)
  image_list = @ec2.describe_images(:owners => ["self"], :filters => [{:name => 'name', :values => [instance_id + '-*']}])[:images_set]
  sort_list = image_list.sort { |a,b| b[:name] <=> a[:name] }
  return sort_list[backup_config[:generation].to_i, sort_list.length]
end

## タグが正常にセットされているかを確認する
if check_backup_config(instance_id)[:flag] == true && check_backup_config(instance_id)[:generation] != nil
  puts "Start backup"
else
  puts "Backup configuration are not correctly"
  exit 1
end

## バックアップ対象であればバックアップ、異なれば終了
@ec2.create_image(:instance_id => instance_id, :description => comment, :name => image_name, :no_reboot => true)

## バックアップされているもので不要となった世代のものを削除する
delete_images = check_delete_images(instance_id)
unless delete_images.nil?
  puts "Remove old backup"
  delete_images.each do |image|
    @ec2.deregister_image(:image_id => image[:image_id])
    image[:block_device_mapping].each do |device|
      @ec2.delete_snapshot(:snapshot_id => device[:ebs][:snapshot_id])
    end
  end
else
  puts "No image to be deleted"
  exit 0
end
