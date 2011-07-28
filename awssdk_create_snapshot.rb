# -*- coding: utf-8 -*-
require 'rubygems'
require 'aws-sdk'

## アクセスIDとシークレットアクセスキーを指定します
ACCESS_KEY = 'SET UP YOUR ACCESS KEY'
SECRET_KEY = 'SET UP YOUR SECRET KEY'

## 引数チェック
unless ARGV.size == 4
  puts 'Usage: awssdk_create_snapshot.rb <aws_region_url> <num> <volume_id> <snapshot_description>'
  exit 0
end

## 引数からスナップショット保存設定を行います
aws_region = ARGV[0]
history = ARGV[1].to_i
vol_id = ARGV[2]
snapshot_memo = ARGV[3]

## スナップショットのdescriptionを作成します
snapshot_description = "#{snapshot_memo} #{Time.now.strftime('%Y/%m/%d %H:%M')}"

## EC2インスターフェースを作成するために認証を行います
AWS.config(:access_key_id => ACCESS_KEY, :secret_access_key => SECRET_KEY, :ec2_endpoint => aws_region)
ec2 = AWS::EC2.new

## 対象ボリュームからスナップショットを作成します
ec2.snapshots.create(:volume => ec2.volumes[vol_id], :description => snapshot_description)

## 現在保存されている対象ボリュームから作成されたスナップショットをリスト化する
snapshots_list = []
snapshots = ec2.snapshots.filter('volume-id', vol_id)
snapshots.each { |snap| snapshots_list << snap.id }

## 指定世代分を残して古いスナップショットを削除します
snapshots_to_delete = []
snapshots_list.each { |snap| snapshots_to_delete << ec2.snapshots[snap] }
snapshots_to_delete = snapshots_to_delete.sort_by { |snap| snap.start_time }.reverse
snapshots_to_delete.each_with_index do |snap, i|
  snap.delete unless i < history
end
