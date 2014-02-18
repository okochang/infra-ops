# -*- coding: utf-8 -*- 
## AWSのIAM用APIを使ってみたログであり、スクリプトではありません。
require 'aws-sdk'
ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'
alias_name = 'okochang'
user_name = 'yanase'
user_policy_name = 'admin_user_policy'
user_policy = '{"Statement":[{"Effect":"Deny","Action":["support:*"],"Resource":"*"},{"Effect":"Allow","Action":"*","Resource":"*"}]}'
group_name = 'administrator'
group_policy_name = 'admin_group_policy'
group_policy = '{"Statement":[{"Effect":"Deny","Action":["support:*"],"Resource":"*"},{"Effect":"Allow","Action":"*","Resource":"*"}]}'
password = 'your_password'
role_name = 'ec2-role'
role_policy_name = 'ec2_admin_role_policy'
assume_role_policy = '{"Statement":[{"Effect":"Allow","Principal":{"Service":["ec2.amazonaws.com"]},"Action":["sts:AssumeRole"]}]}'
role_policy = '{"Statement": [{"Effect":"Allow","Action":"*","Resource":"*"}]}'

iam = AWS::IAM.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY
).client

## アカウントエイリアスを作成します
iam.create_account_alias(:account_alias=> alias_name)

## IAMユーザーを作成します
iam.create_user(:user_name => user_name)
 => {:user=>{:user_id=>"AIDAJMQPZCVVN2N3VB6F6", :path=>"/", :user_name=>"yanase", :arn=>"arn:aws:iam::975450034499:user/yanase", :create_date=>2013-05-29 15:48:13 UTC}, :response_metadata=>{:request_id=>"2b858428-c877-11e2-abdc-13f7a6c2fa89"}} 

## IAMユーザーポリシーを作成します
iam.put_user_policy(:user_name => user_name, :policy_name => user_policy_name, :policy_document => user_policy)
 => {:response_metadata=>{:request_id=>"7a1f486b-c877-11e2-b2db-2f18d5db5f10"}}

## IAMグループを作成します
iam.create_group(:group_name => group_name)
 => {:group=>{:group_id=>"AGPAJDCBOK3TPNQV4J27G", :group_name=>"administrator", :path=>"/", :arn=>"arn:aws:iam::975450034499:group/administrator", :create_date=>2013-05-29 15:53:57 UTC}, :response_metadata=>{:request_id=>"f8ecd520-c877-11e2-b69f-813612a072b8"}} 

## IAMグループポリシーを作成します
iam.put_group_policy(:group_name => group_name, :policy_name => group_policy_name, :policy_document => group_policy)
 => {:response_metadata=>{:request_id=>"1b03a32a-c878-11e2-8421-e51df3ba304c"}} 

## IAMユーザーをIAMグループに割り当てます
iam.add_user_to_group(:user_name => user_name, :group_name => group_name)
 => {:response_metadata=>{:request_id=>"76140460-c878-11e2-9bbc-ab6be7adbd22"}} 

## IAMユーザーをManagement Consoleにログイン可能にします
iam.create_login_profile(:user_name => user_name, :password => password)
 => {:login_profile=>{:user_name=>"yanase", :create_date=>2013-05-29 16:14:08 UTC, :must_change_password=>"false"}, :response_metadata=>{:request_id=>"ca7867e9-c87a-11e2-b93e-478ac9c0919e"}} 

## IAMユーザーにアクセスキーとシークレットアクセスキーのペアを作成します
iam.create_access_key(:user_name => user_name)
 => {:access_key=>{:secret_access_key=>"UtclK8EkkBXab9O3a3btOaAc1QDve3VHipBJbfCZ", :status=>"Active", :access_key_id=>"AKIAJR3SW4SCFZNUKW5Q", :user_name=>"yanase", :create_date=>2013-05-29 16:15:48 UTC}, :response_metadata=>{:request_id=>"06149147-c87b-11e2-8d39-e3a125f625ee"}} 

## IAM Roleを作成します
iam.create_role(:role_name => role_name, :assume_role_policy_document => assume_role_policy)
 => {:role=>{:path=>"/", :arn=>"arn:aws:iam::975450034499:role/ec2-role", :role_name=>"ec2-role", :assume_role_policy_document=>"%7B%22Statement%22%3A%5B%7B%22Effect%22%3A%22Allow%22%2C%22Principal%22%3A%7B%22Service%22%3A%5B%22ec2.amazonaws.com%22%5D%7D%2C%22Action%22%3A%5B%22sts%3AAssumeRole%22%5D%7D%5D%7D", :create_date=>2013-05-29 16:33:49 UTC, :role_id=>"AROAJX3O25EBUTHWZXEME"}, :response_metadata=>{:request_id=>"8a6b964e-c87d-11e2-8421-e51df3ba304c"}}

## IAM Roleポリシーを作成します
iam.put_role_policy(:role_name => role_name, :policy_name => role_policy_name, :policy_document => role_policy)
 => {:response_metadata=>{:request_id=>"ed689f2f-c87d-11e2-8421-e51df3ba304c"}} 

## 作成したRoleを削除します
iam.delete_role_policy(:role_name => role_name, :policy_name => role_policy_name)
 => {:response_metadata=>{:request_id=>"6217d67a-c87e-11e2-8421-e51df3ba304c"}} 

iam.delete_role(:role_name => role_name)
 => {:response_metadata=>{:request_id=>"6a259aef-c87e-11e2-b93e-478ac9c0919e"}} 

## 作成したグループを削除します
iam.remove_user_from_group(:user_name => user_name, :group_name => group_name)
 => {:response_metadata=>{:request_id=>"db3787d1-c87e-11e2-b69f-813612a072b8"}} 

iam.delete_group_policy(:group_name => group_name, :policy_name => group_policy_name)
 => {:response_metadata=>{:request_id=>"a3d92eb7-c87e-11e2-874c-a5a57125af0d"}} 

iam.delete_group(:group_name => group_name)
 => {:response_metadata=>{:request_id=>"e572b30a-c87e-11e2-b69f-813612a072b8"}} 

## 作成したユーザーを削除します
iam.delete_access_key(:user_name => user_name, :access_key_id => 'AKIAJR3SW4SCFZNUKW5Q')
 => {:response_metadata=>{:request_id=>"679f48b1-c87f-11e2-8ed1-4fc9668e9920"}} 

iam.delete_login_profile(:user_name => user_name)
 => {:response_metadata=>{:request_id=>"20b41277-c87f-11e2-8421-e51df3ba304c"}} 

iam.delete_user_policy(:user_name => user_name, :policy_name => user_policy_name)
 => {:response_metadata=>{:request_id=>"05a8177c-c87f-11e2-8ed4-9b2cda5997b1"}} 

iam.delete_user(:user_name => user_name)
 => {:response_metadata=>{:request_id=>"74a3f4b6-c87f-11e2-874c-a5a57125af0d"}} 

## 作成したアカウントエイリアスを削除します
iam.delete_account_alias(:account_alias => alias_name)
 => {:response_metadata=>{:request_id=>"9c76a86e-c87f-11e2-8ed1-4fc9668e9920"}} 
