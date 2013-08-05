# -*- coding: utf-8 -*-
require 'aws-sdk'

ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'
EC2_REGION = 'ec2.ap-southeast-1.amazonaws.com'

ec2 = AWS::EC2.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :ec2_endpoint => EC2_REGION
).client

## 設定
source_region = 'ap-northeast-1'
source_image_id = 'ami-16f94617'
image_name = 'okochang-test-copy'
description = 'test image copy'

## AMIのコピーを行います
singapore_image_id = ec2.copy_image(
  :source_region => source_region,
  :source_image_id => source_image_id,
  :name => image_name,
  :description => description
)[:image_id]

## コピーしたイメージを確認します（コピー中）
ec2.describe_images(:image_ids => [singapore_image_id])[:image_index]
 => {"ami-72fab720"=>{:product_codes=>[], :block_device_mapping=>[], :tag_set=>[], :image_id=>"ami-72fab720", :image_location=>"N/A", :image_state=>"pending", :image_owner_id=>"************", :is_public=>false, :architecture=>"i386", :image_type=>"machine", :root_device_type=>"instance-store", :virtualization_type=>"paravirtual", :hypervisor=>"xen"}} 

## コピーしたイメージを確認します（コピー完了後）
ec2.describe_images(:image_ids => [singapore_image_id])[:image_index]
 => {"ami-72fab720"=>{:product_codes=>[], :block_device_mapping=>[{:device_name=>"/dev/sda1", :ebs=>{:snapshot_id=>"snap-d9f206eb", :delete_on_termination=>true, :volume_type=>"standard"}}], :tag_set=>[], :image_id=>"ami-72fab720", :image_location=>"************/okochang-test-copy", :image_state=>"available", :image_owner_id=>"************", :is_public=>false, :architecture=>"x86_64", :image_type=>"machine", :kernel_id=>"aki-aa225af8", :name=>"okochang-test-copy", :description=>"test image copy", :root_device_type=>"ebs", :root_device_name=>"/dev/sda1", :virtualization_type=>"paravirtual", :hypervisor=>"xen"}} 
