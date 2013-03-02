# -*- coding: utf-8 -*- 

## Auto Scalingの作成〜削除までの流れをまとめました、スクリプトではないので注意して下さい。
require 'aws-sdk'
ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'
AS_REGION = 'autoscaling.ap-southeast-1.amazonaws.com'
CW_REGION = 'monitoring.ap-southeast-1.amazonaws.com'

as = AWS::AutoScaling.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :auto_scaling_endpoint => AS_REGION
).client

cw = AWS::CloudWatch.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :cloud_watch_endpoint => CW_REGION
).client

## もろもろの設定
ami_id = 'ami-xxxxxxxx'
launch_config = 'okochang-launch-config'
ssh_key = 'okochang-ssh-key'
security_group = 'okochang-security-group'
instance_type = 't1.micro'
auto_scaling_group = "okochang-autoscaling-group"
elb = 'okochang-elb'
zone_a = 'ap-southeast-1a'
zone_b = 'ap-southeast-1b'
scaleout_policy = 'okochang-scaleout-policy'
scalein_policy = 'okochang-scalein-policy'
scaleout_alarm = 'okochang-scaleout-alarm'
scalein_alarm = 'okochag-scalein-alarm'
scaleout_metric 
description = 'hoge'
min_size = 2
max_size = 4

## Launch Configurationを作成する
as.create_launch_configuration(
:launch_configuration_name => launch_config,
:image_id => ami_id,
:key_name => ssh_key,
:security_groups => [security_group],
:instance_type => instance_type,
)

## Auto Scaling Groupを作成します
as.create_auto_scaling_group(
:auto_scaling_group_name => auto_scaling_group,
:launch_configuration_name => launch_config,
:min_size => min_size,
:max_size => max_size,
:default_cooldown => 60,
:availability_zones => [zone_a, zone_b],
:load_balancer_names =>  [elb],
:health_check_type => 'ELB',
:health_check_grace_period => 90,
)

## スケールアウトポリシーを作成します
as.put_scaling_policy(
:auto_scaling_group_name => auto_scaling_group,
:policy_name => scaleout_policy,
:scaling_adjustment => 2,
:adjustment_type => 'ChangeInCapacity',
:cooldown => 120,
)

## スケールインポリシーを作成する
as.put_scaling_policy(
:auto_scaling_group_name => auto_scaling_group,
:policy_name => scalein_policy,
:scaling_adjustment => -2,
:adjustment_type => 'ChangeInCapacity',
:cooldown => 120,
)

## スケールアウト／インのARNを変数に格納する
scaleout_arn = as.describe_policies(:policy_names => [scaleout_policy])[:scaling_policies][0][:policy_arn]
scalein_arn = as.describe_policies(:policy_names => [scalein_policy])[:scaling_policies][0][:policy_arn]

## スケールアウトトリガーを設定する
cw.put_metric_alarm(
:alarm_name => scaleout_alarm,
:alarm_description => description,
:actions_enabled => true,
:alarm_actions => [scaleout_arn],
:metric_name => 'CPUUtilization',
:namespace => 'AWS/EC2',
:statistic => 'Average',
:dimensions => [{:name => 'AutoScalingGroupName', :value => auto_scaling_group}],
:period => 300,
:evaluation_periods => 1,
:threshold => 70,
:comparison_operator => 'GreaterThanThreshold',
)

## スケールイントリガーを設定する
cw.put_metric_alarm(
:alarm_name => scalein_alarm,
:alarm_description => description,
:actions_enabled => true,
:alarm_actions => [scalein_arn],
:metric_name => 'CPUUtilization',
:namespace => 'AWS/EC2',
:statistic => 'Average',
:dimensions => [{:name => 'AutoScalingGroupName', :value => auto_scaling_group}],
:period => 300,
:evaluation_periods => 1,
:threshold => 30,
:comparison_operator => 'LessThanThreshold',
)

## Launch Configurationを確認する
as.describe_launch_configurations[:launch_configurations]
as.describe_launch_configurations(:launch_configuration_names => [launch_config])[:launch_configurations]

## Auto Scaling Groupを確認する
as.describe_auto_scaling_groups[:auto_scaling_groups]
as.describe_auto_scaling_groups(:auto_scaling_group_names => [auto_scaling_group])[:auto_scaling_groups]

## Auto Scalingで起動しているインスタンスを確認する
as.describe_auto_scaling_instances[:auto_scaling_instances]

## Auto Scalingのポリシーを確認する
as.describe_policies(:auto_scaling_group_name => auto_scaling_group)[:scaling_policies]
as.describe_policies(:policy_names => [scaleout_policy])
as.describe_policies(:policy_names => [scalein_policy])

## スケールのトリガーを確認する
cw.describe_alarms[:metric_alarms]
cw.describe_alarms(:alarm_names => [scaleout_alarm])[:metric_alarms]
cw.describe_alarms(:alarm_names => [scalein_alarm])[:metric_alarms]

## 動作確認をしたら以下のように削除する
cw.delete_alarms(:alarm_names => [scaleout_alarm, scalein_alarm])
as.delete_policy(:auto_scaling_group_name => auto_scaling_group, :policy_name => scaleout_policy)
as.delete_policy(:auto_scaling_group_name => auto_scaling_group, :policy_name => scalein_policy)
as.delete_auto_scaling_group(:auto_scaling_group_name => auto_scaling_group, :force_delete => true)
as.delete_launch_configuration(:launch_configuration_name => launch_config)


