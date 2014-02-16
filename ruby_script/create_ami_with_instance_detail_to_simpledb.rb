# -*- coding: utf-8 -*-
require 'net/http'
require 'aws-sdk'

## 自分自身の情報を取得する
ec2_region  = "ec2.#{Net::HTTP.get('169.254.169.254', '/latest/meta-data/placement/availability-zone').chop}.amazonaws.com"
sdb_region  = "sdb.#{Net::HTTP.get('169.254.169.254', '/latest/meta-data/placement/availability-zone').chop}.amazonaws.com"
instance_id = Net::HTTP.get('169.254.169.254', '/latest/meta-data/instance-id')
image_name  = "#{instance_id}-#{Time.now.strftime("%Y%m%d%H%M")}"
domain_name = 'ami_backup'
description = 'automatically generated image'
generation  = 3

class Ec2Base

  def initialize(ec2_region)
    @ec2 = AWS::EC2.new(ec2_endpoint: ec2_region).client
  end
 
  def get_instance_datas(instance_id)
    @ec2.describe_instances(instance_ids: ["#{instance_id}"])[:instance_index][instance_id]
  end

  def get_api_termination(instance_id)
    @ec2.describe_instance_attribute(
      instance_id: instance_id,
      attribute: "disableApiTermination"
    )[:disable_api_termination][:value]
  end

  def get_shutdown_behavior(instance_id)
    @ec2.describe_instance_attribute(
      instance_id: instance_id,
      attribute: "instanceInitiatedShutdownBehavior"
    )[:instance_initiated_shutdown_behavior][:value]
  end

  def create_image(instance_id, image_name, description)
    puts "Start image creation"
    @ec2.create_image(
      instance_id: instance_id,
      name: image_name,
      description: description,
      no_reboot: true
    )[:image_id]
  end

  def image_status(image_id)
    30.times do
      if @ec2.describe_images(image_ids: ["#{image_id}"])[:images_set][0][:image_state] == "available"
        puts "Image status became availabled"
        break
      else
        sleep 10
      end
    end
  end

  def get_deleted_image(instance_id, generation)
    image_list = @ec2.describe_images(
      owners: ["self"],
      filters: [{name: 'name', values: ["#{instance_id}" + "-*"]}]
    )[:images_set].sort { |a,b| b[:name] <=> a[:name] }
    delete_target = image_list[generation.to_i, image_list.length]
  end

  def delete_image(deleted_image_ids)
    unless deleted_image_ids.nil?
      puts "Remove old images"
      deleted_image_ids.each do |image|
        @ec2.deregister_image(image_id: image[:image_id])
        image[:block_device_mapping].each do |device|
          @ec2.delete_snapshot(snapshot_id: device[:ebs][:snapshot_id])
        end
      end
    else
      puts "No image to be deleted"
      exit 0
    end
  end

end

class SimpledbBase

  def initialize(sdb_region)
    @sdb = AWS::SimpleDB.new(simple_db_endpoint: sdb_region).client
  end
  
  def put_data_to_simpledb(image_id, insert_datas, domain_name)
    @sdb.put_attributes(
      domain_name: domain_name,
      item_name: image_id,
      attributes: [
        { name: "instance_type",                        value: insert_datas[:instance_type]},
        { name: "subnet_id",                            value: insert_datas[:subnet_id]},
        { name: "local_ip_address",                     value: insert_datas[:local_ip_address] },
        { name: "key_name",                             value: insert_datas[:key_name] },
        { name: "security_group_ids",                   value: insert_datas[:security_group_ids].join(" ") },
        { name: "source_dest_check",                    value: insert_datas[:source_dest_check].to_s},
        { name: "disable_api_termination",              value: insert_datas[:disaable_api_termination].to_s },
        { name: "monitoring",                           value: insert_datas[:monitoring] },
        { name: "iam_instance_profile",                 value: insert_datas[:iam_instance_profile] },
        { name: "tag_set",                              value: insert_datas[:tag_set].join(" ") },
        { name: "instance_initiated_shutdown_behavior", value: insert_datas[:instance_initiated_shutdown_behavior].to_s },
        { name: "vpc_id",                               value: insert_datas[:vpc_id] }
      ])
    puts "Putted tags to simpledb"
  end
  
  def delete_data_from_simpledb(domain_name, deleted_image_ids)
    unless deleted_image_ids.nil?
      puts "Removed old image's item from simpledb"
      deleted_image_ids.each do |image|
        @sdb.delete_attributes(domain_name: domain_name, item_name: image[:image_id])
      end
    else
      puts "No image to be deleted"
      exit0
    end
  end
  
end

# AMIのタグに必要な情報を取得する
ec2  = Ec2Base.new(ec2_region)
insert_datas = Hash.new
instance_datas = ec2.get_instance_datas(instance_id)
security_group_ids = []

insert_datas[:instance_type]            = instance_datas[:instance_type]
insert_datas[:availability_zone]        = instance_datas[:placement][:availability_zone]
insert_datas[:iam_instance_profile]     = instance_datas[:iam_instance_profile][:arn]
insert_datas[:instance_type]            = instance_datas[:instance_type]
insert_datas[:key_name]                 = instance_datas[:key_name]
insert_datas[:local_ip_address]         = instance_datas[:private_ip_address]
insert_datas[:monitoring]               = instance_datas[:monitoring][:state]
insert_datas[:security_group_ids]       = instance_datas[:group_set].each {|group_set| security_group_ids << group_set[:group_id]}
insert_datas[:source_dest_check]        = instance_datas[:source_dest_check]
insert_datas[:subnet_id]                = instance_datas[:subnet_id]
insert_datas[:tag_set]                  = instance_datas[:tag_set]
insert_datas[:vpc_id]                   = instance_datas[:vpc_id]
insert_datas[:disaable_api_termination] = ec2.get_api_termination(instance_id)
insert_datas[:shutdown_behavior]        = ec2.get_shutdown_behavior(instance_id)

## AMIを作成
image_id = ec2.create_image(instance_id, image_name, description)

ec2.image_status(image_id)

## SimpleDBにインスタンスの情報を入れる
sdb = SimpledbBase.new(sdb_region)
sdb.put_data_to_simpledb(image_id, insert_datas, domain_name)

## 不要なAMIとItemを削除
deleted_image_ids = ec2.get_deleted_image(instance_id, generation)
ec2.delete_image(deleted_image_ids)
sdb.delete_data_from_simpledb(domain_name, deleted_image_ids)

