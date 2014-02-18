# -*- coding: utf-8 -*-
require 'aws-sdk'

## 設定
access_key = 'set your access key'
secret_key = 'set your secret key'
rds_region = 'rds.ap-northeast-1.amazonaws.com'
rds_db_identifier = 'set your db identifier'
script_identifier = 'rotate-script'
copied_snapshot_name = rds_db_identifier + '-' +  script_identifier + Time.now.strftime("%Y-%m-%d")
generation = 3

## AWSにログオンします 
@rds = AWS::RDS.new(
  :access_key_id => access_key,
  :secret_access_key => secret_key,
  :rds_endpoint => rds_region
).client

## 自動で取得された最新のスナップショットを特定します
def search_target_snapshot(rds_db_identifier)
  auto_snapshots_list = @rds.describe_db_snapshots(
    :db_instance_identifier => rds_db_identifier,
    :snapshot_type => 'automated'
  )[:db_snapshots]
  target_snapshots_list = auto_snapshots_list.sort {|a,b|
    b[:snapshot_create_time] <=> a[:snapshot_create_time]
  }
  return target_snapshots_list[0]
end

## 自動で取得された最新のスナップショットをコピーします
def copy_target_snapshot(rds_db_identifier, copied_snapshot_name)
  target_snapshot = search_target_snapshot(rds_db_identifier)
  created_snapshot = @rds.copy_db_snapshot(
    :source_db_snapshot_identifier => target_snapshot[:db_snapshot_identifier],
    :target_db_snapshot_identifier => copied_snapshot_name
  )
  puts created_snapshot[:db_snapshot_identifier] + ' was created'
end

## スクリプトによってコピーされたスナップショットの一覧を作成します
def search_copied_snapshots(rds_db_identifier, script_identifier)
  auto_snapshots_list = @rds.describe_db_snapshots(
    :db_instance_identifier => rds_db_identifier,
    :snapshot_type => 'manual'
  )[:db_snapshots]
  copied_snapshots_list = auto_snapshots_list.select { |n| n[:db_snapshot_identifier] =~ /#{rds_db_identifier}-#{script_identifier}/ }
  sorted_snapshots_list = copied_snapshots_list.sort {|a,b|
    b[:snapshot_create_time] <=> a[:snapshot_create_time]
  }
  return sorted_snapshots_list
end

## スクリプトによってコピーされたスナップショットの一覧から指定した世代より古いものを削除します
def remove_old_snapshots(rds_db_identifier, script_identifier, generation)
  copied_snapshot_list = search_copied_snapshots(rds_db_identifier, script_identifier)
  if copied_snapshot_list[generation...copied_snapshot_list.length].nil?
    puts "There is no old snapshots for the specified"
  else
    copied_snapshot_list[generation...copied_snapshot_list.length].each do |snapshot|
      @rds.delete_db_snapshot(:db_snapshot_identifier => snapshot[:db_snapshot_identifier])
      puts snapshot[:db_snapshot_identifier] + ' was deleted'
    end
  end
end

## 実行
copy_target_snapshot(rds_db_identifier, copied_snapshot_name)
remove_old_snapshots(rds_db_identifier, script_identifier, generation)
