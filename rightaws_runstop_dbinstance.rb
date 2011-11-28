# -*- coding: utf-8 -*-
require 'rubygems'
require 'right_aws'

### 事前に指定するパラメータ
# * RDSのdbinstance名
# * RDSのユーザー名
# * RDSのパスワード
# * RDSのパラーメタグループ
# * RDSのセキュリティグループ
rds_db_instance = ARGV[0]

### スクリプト内に埋め込む設定
# * AWSのリージョン設定
# * DBのバージョン
# * バックアップウィンドウ
# * メンテナンスウィンドウ
rds_end_point_url = 'ap-north-1.rds.amazonaws.com'

## アクセスIDとシークレットアクセスキーを指定します
ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'

## RDSのインスターフェースを作成するために認証をします
rds = RightAws::RdsInterface.new(ACCESS_KEY, SECRET_KEY, :default_endpoint_url => rds_end_point_url)

## DB削除時に作成するファイナルスナップショットの名前を作成します
today = Time.now
final_db_snapshot = "#{rds_db_instance}-#{today.strftime('%Y-%m-%d-%H-%M')}"

## DBリストアの元となる最新のスナップショットのリストを作成します
db_snapshots_list = []
rds.describe_db_snapshots.each do |dbsnapshot|
  if rds_db_instance == dbsnapshot[:instance_aws_id]
    db_snapshots_list << dbsnapshot
  end
end

## リストア候補のスナップショットをスナップショット作成日時でソートします
sorted_db_snapshots_list = db_snapshots_list.sort do |a, b|
  b[:create_time] <=> a[:create_time]
end

## ソートされたスナップショットの候補から最新のスナップショットを特定します
restore_db_snapshot = sorted_db_snapshots_list[0]

## 指定した名前のDBインスタンスが起動している場合はリストに入れときます
check_db_instance = []
rds.describe_db_instances.each do |dbinstance|
  if rds_db_instance == dbinstance[:aws_id]
    check_db_instance << dbinstance
  end
end

## 指定した名前のDBインスタンスが起動していなければ最新のスナップショットからDBをリストアします
## 指定した名前のDBインスタンスが起動していればファイナルスナップショットを所得してDBインスタンスを削除します
if check_db_instance.size == 0
  rds.restore_db_instance_from_db_snapshot("#{restore_db_snapshot[:aws_id]}", rds_db_instance, params={})
elsif check_db_instance.size != 0
  rds.delete_db_instance(rds_db_instance, params={:snapshot_aws_id => final_db_snapshot})
end

