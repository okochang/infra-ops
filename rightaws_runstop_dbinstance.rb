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
rds_db_paramater = ARGV[1]
rds_db_security_group = ARGV[2]

### スクリプト内に埋め込む設定
# * AWSのリージョン設定
# * DBのバージョン
# * バックアップウィンドウ
# * メンテナンスウィンドウ
rds_end_point_url = 'ap-north-1.rds.amazonaws.com'

## アクセスIDとシークレットアクセスキーを指定します
ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'

## DB削除時に作成するファイナルスナップショットの名前を作成します
today = Time.now
final_db_snapshot = "#{rds_db_instance}-#{today.strftime('%Y-%m-%d')}"

## DBリストアの元となるファイナルスナップショットの名前を作成します
yesterday = today - 86400
yesterday_db_snapshot = "#{rds_db_instance}-#{yesterday.strftime('%Y-%m-%d')}"

## RDSのインスターフェースを作成するために認証をします
rds = RightAws::RdsInterface.new(ACCESS_KEY, SECRET_KEY, :default_endpoint_url => rds_end_point_url)

## 指定した名前のDBが存在するかチェックします
check_db_instance = []
rds.describe_db_instances.each do |dbinstance|
  if rds_db_instance == dbinstance[:aws_id]
    check_db_instance << dbinstance
  end
end

## check_dbinstanceのサイズが0ならば前日のスナップショットからRDSインスタンスを作成
## check_dbinstanceのサイズが0以外ならば稼働中のDBインスタンスからファイナルスナップショットを取得して削除
if check_db_instance.size == 0
  rds.restore_db_instance_from_db_snapshot(yesterday_db_snapshot, rds_db_instance, params={})
elsif check_db_instance.size != 0
  rds.delete_db_instance(rds_db_instance, params={:snapshot_aws_id => final_db_snapshot, :db_security_groups => rds_db_security_group})
end

