# -*- coding: utf-8 -*- 
## ELBを起動するまでの流れです。スクリプトではないので注意して下さい

require 'aws-sdk'

## 設定
ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'
ELB_REGION = 'elasticloadbalancing.ap-southeast-1.amazonaws.com'
elb_name = 'okochang-elb'
zone_a = 'ap-southeast-1a'
zone_b = 'ap-southeast-1b'
instance_id = 'i-xxxxxxxx'

elb = AWS::ELB.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :elb_endpoint => ELB_REGION
).client

## ELBを作成します
elb.create_load_balancer(
:load_balancer_name => elb_name,
:listeners => [:protocol => 'HTTP', :load_balancer_port => 80, :instance_protocol => 'HTTP', :instance_port => 80],
:availability_zones => [zone_a, zone_b],
)

## ELBのヘルスチェックを設定します
elb.configure_health_check(
:load_balancer_name => elb_name,
:health_check => {:target => 'HTTP:80/healthcheck.html', :interval => 30, :timeout => 5, :unhealthy_threshold => 3, :healthy_threshold => 3}
)

## 作成したELBにインスタンスを紐付けます
elb.register_instances_with_load_balancer(
:load_balancer_name => elb_name,
:instances => [:instance_id => instance_id]
)

## 作成したELBを確認します
elb.describe_load_balancers[:load_balancer_descriptions][0]

## ELB配下に紐付いたインスタンスを確認します
elb.describe_instance_health(:load_balancer_name => elb_name)[:instance_states][0]

## ELB配下に紐付いたインスタンスを個別指定して確認します
elb.describe_instance_health(:load_balancer_name => elb_name, :instances => [:instance_id => instance_id])[:instance_states][0]

## ELB配下に紐付いたインスタンスを外します
elb.deregister_instances_from_load_balancer(:load_balancer_name => elb_name, :instances => [:instance_id => instance_id])

## 使い終わったら忘れずに削除します
elb.delete_load_balancer(:load_balancer_name => elb_name)
