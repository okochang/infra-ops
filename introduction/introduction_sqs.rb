# -*- coding: utf-8 -*-
require 'aws-sdk'
access_key = 'set your access key'
secret_key = 'set your secret key'
sqs_region = 'sqs.ap-northeast-1.amazonaws.com'
queue_name = 'okochang_que'

sqs = AWS::SQS.new(
  :access_key => access_key,
  :secret_key => secret_key,
  :sqs_endpoint => sqs_region
).client

## キューを作成します
sqs.create_queue(:queue_name => queue_name)

## ちなみにattributeをカスタマイズしてキューを作成する場合は以下のように
sqs.create_queue(:queue_name => queue_name, :attributes => {"VisibilityTimeout" => "60"})

## 作成されたキューを一覧します
sqs.list_queues[:queue_urls]

## Prefixを指定する事も出来る
sqs.list_queues(:queue_name_prefix => queue_name)

## 作成されたキューのURLを取得します
queue_url = sqs.get_queue_url(:queue_name => queue_name)[:queue_url]

## 作成したキューにメッセージを入れます
sqs.send_message(:queue_url => queue_url, :message_body => "Hello SQS")

## キューに入れたメッセージを受け取ります
message = sqs.receive_message(:queue_url => queue_url)[:messages][0]

## 受け取ったメッセージを出力します
puts message[:body]

## キューに入れたメッセージを削除します
sqs.delete_message(:queue_url => queue_url, :receipt_handle => message[:receipt_handle])

## メッセージが削除されたかを確認します
sqs.receive_message(:queue_url => queue_url)[:messages]

## ちなみにVisibilityTimeoutはこのように取得が出来ます
sqs.get_queue_attributes(:queue_url => queue_url, :attribute_names => ["VisibilityTimeout"])

## 最後にキューを削除します
sqs.delete_queue(:queue_url => queue_url)

