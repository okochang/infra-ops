# -*- coding: utf-8 -*-
require 'net/http'
require 'aws-sdk'

## 自分自身の情報を取得する
ec2_region  = 'ec2.' + Net::HTTP.get('169.254.169.254', '/latest/meta-data/placement/availability-zone').chop + '.amazonaws.com'
instance_id = Net::HTTP.get('169.254.169.254', '/latest/meta-data/instance-id')
image_name  = instance_id + '-' + Time.now.strftime("%Y%m%d%H%M")
description = "automatically generated image"
generation  = 3

class InstanaceDatas
 
  def initialize(ec2_region, instance_id)
    @ec2 = AWS::EC2.new(:ec2_endpoint => ec2_region).client
    @instance_datas = @ec2.describe_instances(
      :instance_ids => [instance_id]
    )[:instance_index][instance_id]
  end

  def get_instance_type
    @instance_datas[:instance_type]
  end

  def get_availability_zone
    @instance_datas[:placement][:availability_zone]
  end

  def get_vpc_id
    @instance_datas[:vpc_id]
  end

  def get_subnet_id
    @instance_datas[:subnet_id]
  end

  def get_local_ip_address
    @instance_datas[:private_ip_address]
  end

  def get_security_group_ids
    security_group_ids = []
    @instance_datas[:group_set].each do |group_set|
      security_group_ids << group_set[:group_id]
    end
    return security_group_ids
  end

  def get_source_dest_check
    @instance_datas[:source_dest_check]
  end

  def get_monitoring
    @instance_datas[:monitoring][:state]
  end

  def get_iam_instance_profile
    @instance_datas[:iam_instance_profile][:arn]
  end

  def get_tag_set
    @instance_datas[:tag_set]
  end

  def get_key_name
    @instance_datas[:key_name]
  end
end

class InstanceAttributes

  def initialize(ec2_region)
    @ec2 = AWS::EC2.new(:ec2_endpoint => ec2_region).client
  end

  def get_api_termination(instance_id)
    @ec2.describe_instance_attribute(
      :instance_id => instance_id,
      :attribute   => "disableApiTermination"
    )[:disable_api_termination][:value]
  end

  def get_shutdown_behavior(instance_id)
    @ec2.describe_instance_attribute(
      :instance_id => instance_id,
      :attribute   => "instanceInitiatedShutdownBehavior"
    )[:instance_initiated_shutdown_behavior][:value]
  end

end

class AmiBackup

  def initialize(ec2_region)
    @ec2 = AWS::EC2.new(:ec2_endpoint => ec2_region).client
  end

  def create_image(instance_id, image_name, description)
    @ec2.create_image(
      :instance_id => instance_id,
      :name        => image_name,
      :description => description,
      :no_reboot   => true
    )[:image_id]
  end

  def image_status(image_id)
    30.times do
      if @ec2.describe_images(:image_ids => [image_id])[:images_set][0][:image_state] == "available"
        puts "done"
        break
      else
        sleep 10
      end
    end
  end

  def create_tags(image_id, tag_datas)
    @ec2.create_tags(
      :resources => [image_id],
      :tags => [
        { :key => "instance_type", :value => tag_datas[:instance_type] },
        { :key => "subnet_id", :value => tag_datas[:subnet_id] },
        { :key => "local_ip_address", :value => tag_datas[:local_ip_address] },
        { :key => "key_name", :value => tag_datas[:key_name] },
        { :key => "security_group_ids", :value => tag_datas[:security_group_ids].join(" ") },
        { :key => "source_dest_check", :value => tag_datas[:source_dest_check].to_s },
        { :key => "disable_api_termination", :value => tag_datas[:disaable_api_termination].to_s },
        { :key => "monitoring", :value => tag_datas[:monitoring] },
        { :key => "iam_instance_profile", :value => tag_datas[:iam_instance_profile] },
        { :key => "tag_set", :value => tag_datas[:tag_set].join(" ") }
        ## 上限で以下のものはタグにつけられなかった
        # { :key => "instance_initiated_shutdown_behavior", :value => tag_datas[:instance_initiated_shutdown_behavior] }
        # { :key => "vpc_id", :value => tag_datas[:vpc_id] }
      ]
    )
  end

  def delete_images(instance_id, generation)
    image_list = @ec2.describe_images(
      :owners => ["self"],
      :filters => [{:name => 'name', :values => [instance_id + '-*']}]
    )[:images_set]
    sorted_list = image_list.sort { |a,b| b[:name] <=> a[:name] }
    delete_target = sorted_list[generation.to_i, sorted_list.length]
    unless delete_target.nil?
      puts "Remove old backup"
      delete_target.each do |image|
        @ec2.deregister_image(:image_id => image[:image_id])
        image[:block_device_mapping].each do |device|
          @ec2.delete_snapshot(:snapshot_id => device[:ebs][:snapshot_id])
        end
      end
    else
      puts "No image to be deleted"
      exit 0
    end
  end
 
end

# AMIのタグに必要な情報を取得する
ec2_instance_datas  = InstanaceDatas.new(ec2_region, instance_id)
ec2_instance_attributes = InstanceAttributes.new(ec2_region)
tag_datas = Hash.new
tag_datas[:instance_type]            = ec2_instance_datas.get_instance_type
tag_datas[:availability_zone]        = ec2_instance_datas.get_availability_zone
tag_datas[:iam_instance_profile]     = ec2_instance_datas.get_iam_instance_profile
tag_datas[:instance_type]            = ec2_instance_datas.get_instance_type
tag_datas[:key_name]                 = ec2_instance_datas.get_key_name
tag_datas[:local_ip_address]         = ec2_instance_datas.get_local_ip_address
tag_datas[:monitoring]               = ec2_instance_datas.get_monitoring
tag_datas[:security_group_ids]       = ec2_instance_datas.get_security_group_ids
tag_datas[:source_dest_check]        = ec2_instance_datas.get_source_dest_check
tag_datas[:subnet_id]                = ec2_instance_datas.get_subnet_id
tag_datas[:tag_set]                  = ec2_instance_datas.get_tag_set
tag_datas[:vpc_id]                   = ec2_instance_datas.get_vpc_id
tag_datas[:disaable_api_termination] = ec2_instance_attributes.get_api_termination(instance_id)
tag_datas[:shutdown_behavior]        = ec2_instance_attributes.get_shutdown_behavior(instance_id)

## AMIの作成
ami = AmiBackup.new(ec2_region)
image_id = ami.create_image(instance_id, image_name, description)
ami.image_status(image_id)
ami.create_tags(image_id, tag_datas)

## 不要なAMIの削除
ami.delete_images(instance_id, generation)
