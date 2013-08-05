# -*- coding: utf-8 -*-
require 'aws-sdk'
ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'

support = AWS::Support.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
).client

## サービスの一覧を出力します
aws_services = support.describe_services[:services]
aws_services.each do |service|
  p service[:name]
end
"Alexa Services"
"CloudFront"
"CloudWatch"
== 以下省略 ==

## 問い合わせ内容の一覧を出力します（問い合わせがあれば表示されます）
support.describe_cases(:language => 'ja')
 => {:cases=>[]} 

## Trusted Advisorの項目一覧を出力します
trusted_advisor_menus = support.describe_trusted_advisor_checks(:language => "en")[:checks]
trusted_advisor_menus.each do |menu|
  p menu[:name], menu[:id]
end
"EC2 Reserved Instances Optimization"
"AaBbCcDdEe"
"Underutilized EC2 Instances"
"FfGgHhIiJj"
"Idle Elastic Load Balancers"
"KkLlMmNnOo"
== 以下省略 == 

## Trusted Advisorサマリを出力します（:check_idsには先ほど取得したmenu[:id]を渡します）
support.describe_trusted_advisor_check_summaries(:check_ids => ["HogeFuga"])
 => {:check_id=>"HogeFuga", :timestamp=>"2013-06-13T06:17:08Z", :status=>"ok", :has_flagged_resources=>false, :resources_summary=>{:resources_processed=>141, :resources_flagged=>0, :resources_ignored=>0, :resources_suppressed=>0}, :category_specific_summary=>{}} 

## Trusted Advisorの結果を出力します（エラーがある場合は詳細が表示されます）
support.describe_trusted_advisor_check_result(:check_id => "HogeFuga", :language => "en")
 => {:result=>{:check_id=>"HogeFuga", :timestamp=>"2013-06-13T06:17:08Z", :status=>"ok", :resources_summary=>{:resources_processed=>141, :resources_flagged=>0, :resources_ignored=>0, :resources_suppressed=>0}, :category_specific_summary=>{}, :flagged_resources=>[]}} 

## Trusted Advisorのデータ更新要求を行います
support.refresh_trusted_advisor_check(:check_id => "HogeFuga")
 => {:status=>{:check_id=>"HogeFuga", :status=>"enqueued", :millis_until_next_refreshable=>3599967}} 

## Trusted Advisorの更新状況の確認が出来ます
support.describe_trusted_advisor_check_refresh_statuses(:check_ids => ["HogeFuga"])
 => {:status=>{:check_id=>"HogeFuga", :status=>"success", :millis_until_next_refreshable=>3586396}} 

## プレミアムサポートに加入していないアカウントの場合は以下のようなエラーとなります
support.describe_services
AWS::Support::Errors::SubscriptionRequiredException: AWS Premium Support Subscription is required to use this service.

