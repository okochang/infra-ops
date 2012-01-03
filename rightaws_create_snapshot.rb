require 'rubygems'
require 'bundler/setup'
require 'right_aws'
require 'nkf'
require 'net/smtp'

# このスクリプトでジョブの結果をメールで通知する場合はローカル環境にsmtpサーバが必要です
# 動作確認に使用した環境は以下の通りです
# * ruby 1.8.7
# * postfix 2.3.3
# スクリプトを使用する場合は以下の順番で引数を指定して下さい
# 1. AWSリージョン
# 2. 保存世代
# 3. スナップショットを取得するvolume-id
# 4. スナップショットのdescriptionに使用する名前(英語)
# 5. 転送先e-mailアドレス
# スクリプトを使用する場合は以下の文字列を指定して下さい
# * ACCESS_KEY
# * SECRET_KEY
# * from_mail_addr

# 定数設定
ACCESS_KEY = 'SET UP YOUR ACCESS KEY'
SECRET_KEY = 'SET UP YOUR SECRET KEY'

# 引数チェック
unless ARGV.size == 5 then
  puts '使い方: ebs_snapshot.rb <aws_region> <num> <volume_id> <snapshot_memo> <email_address>'
  exit 0
end

# 引数からスナップショット保存の設定をする
aws_region = ARGV[0]
history = ARGV[1].to_i                                                        # EBSスナップショットを何世代残しておくか
vol_id = ARGV[2]                                                              # EBSスナップショットを取得するEBSボリュームID
snap_name = ARGV[3]                                                           # EBSスナップショットのdescriptionにつける名前
to_mail_addr = ARGV[4]                                                        # バックアップ完了通知先アドレス
from_mail_addr = 'noreply@from_addr.com'                                      # バックアップ完了通知元アドレス
subject = NKF.nkf("-wjm0", 'スナップショット通知メール')                      # スナップショット通知メールタイトル
failure_message = NKF.nkf("-wjm0", 'スナップショットの作成に失敗しました。')  # バックアップ失敗通知メールの本文
success_message = NKF.nkf("-wjm0", '完了しました。スナップショットのリストは以下の通りです。')  # バックアップ成功通知メールの本文

# スナップショットのdescriptionを作成
t = Time.now
snapshot_description = "#{snap_name} #{t.strftime('%Y/%m/%d %H:%M')}"

# EC2のインターフェースを作成するための認証をします
ec2 = RightAws::Ec2.new(ACCESS_KEY, SECRET_KEY, :region => "#{aws_region}")

# スナップショットバックアップの処理
begin
    # 対象のEBSボリュームからスナップショットを作成します
    ec2.create_snapshot(vol_id, snapshot_description)
# スナップショット処理に失敗が発生した場合の処理
rescue => ex
# 失敗時のメッセージを作成する
data = <<EOF
Subject: #{subject}

#{failure_message}
EOF
    # バックアップ失敗通知メールを送信する
    Net::SMTP.start('localhost', 25){ |smtp| smtp.sendmail data, from_mail_addr, to_mail_addr }
    exit
end
# 保存しているスナップショットで、目的のIDを持つものをリスト化する
snapshots_list = []
ec2.describe_snapshots.each do |snapshot|
    if vol_id == snapshot[:aws_volume_id]
        snapshots_list << snapshot
    end
end
    
# 履歴分を残して古いスナップショットを削除
snapshots_list = snapshots_list.sort_by {|snapshot| snapshot[:aws_started_at] }.reverse
snapshots_list.each_with_index do |snapshot, i|
    unless i < history
        ec2.delete_snapshot(snapshot[:aws_id])
    end
end
    
# ジョブ完了後、保存しているスナップショットで、目的のIDを持つものをリスト化する
new_snapshots_list = []
ec2.describe_snapshots.each do |snapshot|
    if vol_id == snapshot[:aws_volume_id]
       new_snapshots_list << snapshot[:aws_description]
       new_snapshots_list << snapshot[:aws_id]
       new_snapshots_list << snapshot[:aws_status]
       new_snapshots_list << "\n"
    end
end
    
# バックアップ完了通知メールの本文を作成
data = <<EOF
Subject: #{subject}

#{success_message}
#{new_snapshots_list}
EOF
# 現在のスナップショットリストを本文にした完了通知メールを送信する
Net::SMTP.start('localhost', 25){|smtp| smtp .sendmail data, from_mail_addr, to_mail_addr }
exit

