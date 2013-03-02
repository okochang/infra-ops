# -*- coding: utf-8 -*- 
require 'aws-sdk'
ACCESS_KEY = "set your access key id"
SECRET_KEY = "set your secret key"
EC_REGION = 'elasticache.ap-northeast-1.amazonaws.com'
EC2_REGION = 'ec2.ap-northeast-1.amazonaws.com'

## ElastiCache用のインターフェースを作成します。
ec = AWS::ElastiCache.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :elasticache_endpoint => EC_REGION
).client

## VPCの場合はセキュリティグループなどがVPCのものと統合されるので、こちらもインターフェースを作成します
ec2 = AWS::EC2.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :ec2_endpoint => EC2_REGION
).client

## VPCの場合はSubnet Groupを作成する必要があります。
ec.create_cache_subnet_group(:cache_subnet_group_name => "yanase-cache-subnet-group", :cache_subnet_group_description => "20130221", :subnet_ids => ["subnet-06270c6f", "subnet-34270c5d", "subnet-0a270c63"])
 => {:subnets=>[{:subnet_identifier=>"subnet-06270c6f", :subnet_availability_zone=>{:name=>"ap-northeast-1b"}}, {:subnet_identifier=>"subnet-0a270c63", :subnet_availability_zone=>{:name=>"ap-northeast-1a"}}, {:subnet_identifier=>"subnet-34270c5d", :subnet_availability_zone=>{:name=>"ap-northeast-1c"}}], :vpc_id=>"vpc-0fc5a566", :cache_subnet_group_description=>"20130221", :cache_subnet_group_name=>"yanase-cache-subnet-group", :response_metadata=>{:request_id=>"ee3077e3-7c39-11e2-b1ff-1fcaa589e549"}} 

## ElastiCache用のセキュリティグループを作成します
ec2.create_security_group(:group_name => "yanase-cache-security-group", :description => "20130221", :vpc_id => "vpc-0fc5a566")
=> {:request_id=>"7dde51a0-c9f4-4d45-b411-020220a4f82a", :return=>"true", :group_id=>"sg-c2bfa0ae"} 

## 作成したセキュリティグループに接続許可のルールを作ります
ec2.authorize_security_group_ingress(:group_id => "sg-c2bfa0ae", :ip_permissions => [:ip_protocol => "tcp", :from_port => 11211, :to_port => 11211, :ip_ranges => [:cidr_ip => "10.0.0.0/16"]])
 => {:request_id=>"bc48556b-c2d4-49f9-a94e-06027de41e52", :return=>"true"} 

## パラメータグループを作ります
ec.create_cache_parameter_group(:cache_parameter_group_name => "yanase-cache-parameter-group", :description => "20130221", :cache_parameter_group_family => "memcached1.4")
 => {:cache_parameter_group_name=>"yanase-cache-parameter-group", :cache_parameter_group_family=>"memcached1.4", :description=>"20130221", :response_metadata=>{:request_id=>"cb100c75-7c3a-11e2-b5e6-0fafaa69a210"}} 

## ElastiCacheのクラスタを作成します。
ec.create_cache_cluster(
:cache_cluster_id => "yanase-cache-cluster",
:num_cache_nodes => 1,
:cache_node_type => "cache.t1.micro",
:engine => "memcached",
:engine_version => "1.4.14",
:cache_parameter_group_name => "yanase-cache-parameter-group",
:cache_subnet_group_name => "yanase-cache-subnet-group",
:security_group_ids => ["sg-c2bfa0ae"],
:preferred_availability_zone => "ap-northeast-1a",
:preferred_maintenance_window => "sat:18:00-sat:19:00",
:port => 11211,
:auto_minor_version_upgrade => true,
)
 => {:cache_security_groups=>[], :cache_nodes=>[], :security_groups=>[{:status=>"active", :security_group_id=>"sg-c2bfa0ae"}], :cache_parameter_group=>{:cache_node_ids_to_reboot=>[], :parameter_apply_status=>"in-sync", :cache_parameter_group_name=>"yanase-cache-parameter-group"}, :cache_cluster_id=>"yanase-cache-cluster", :cache_cluster_status=>"creating", :cache_node_type=>"cache.t1.micro", :engine=>"memcached", :pending_modified_values=>{:cache_node_ids_to_remove=>[]}, :preferred_availability_zone=>"ap-northeast-1a", :engine_version=>"1.4.14", :auto_minor_version_upgrade=>true, :preferred_maintenance_window=>"sat:18:00-sat:19:00", :client_download_landing_page=>"https://console.aws.amazon.com/elasticache/home#client-download:", :cache_subnet_group_name=>"yanase-cache-subnet-group", :num_cache_nodes=>1, :response_metadata=>{:request_id=>"acbf5140-7c3b-11e2-b1ff-1fcaa589e549"}} 

## 作成したクラスタを確認します
ec.describe_cache_clusters[:cache_clusters]
 => [{:cache_security_groups=>[], :cache_nodes=>[], :security_groups=>[{:status=>"active", :security_group_id=>"sg-c2bfa0ae"}], :cache_parameter_group=>{:cache_node_ids_to_reboot=>[], :parameter_apply_status=>"in-sync", :cache_parameter_group_name=>"yanase-cache-parameter-group"}, :cache_cluster_id=>"yanase-cache-cluster", :cache_cluster_status=>"available", :configuration_endpoint=>{:port=>11211, :address=>"yanase-cache-cluster.k9yqoo.cfg.apne1.cache.amazonaws.com"}, :cache_node_type=>"cache.t1.micro", :engine=>"memcached", :pending_modified_values=>{:cache_node_ids_to_remove=>[]}, :preferred_availability_zone=>"ap-northeast-1a", :cache_cluster_create_time=>2013-02-21 15:34:41 UTC, :engine_version=>"1.4.14", :auto_minor_version_upgrade=>true, :preferred_maintenance_window=>"sat:18:00-sat:19:00", :client_download_landing_page=>"https://console.aws.amazon.com/elasticache/home#client-download:", :cache_subnet_group_name=>"yanase-cache-subnet-group", :num_cache_nodes=>1}] 

## 動作確認が終わったら忘れずに削除します
ec.delete_cache_cluster(:cache_cluster_id => "yanase-cache-cluster")
 => {:cache_security_groups=>[], :cache_nodes=>[], :security_groups=>[{:status=>"active", :security_group_id=>"sg-c2bfa0ae"}], :cache_parameter_group=>{:cache_node_ids_to_reboot=>[], :parameter_apply_status=>"in-sync", :cache_parameter_group_name=>"yanase-cache-parameter-group"}, :cache_cluster_id=>"yanase-cache-cluster", :cache_cluster_status=>"deleting", :configuration_endpoint=>{:port=>11211, :address=>"yanase-cache-cluster.k9yqoo.cfg.apne1.cache.amazonaws.com"}, :cache_node_type=>"cache.t1.micro", :engine=>"memcached", :pending_modified_values=>{:cache_node_ids_to_remove=>[]}, :preferred_availability_zone=>"ap-northeast-1a", :cache_cluster_create_time=>2013-02-21 15:34:41 UTC, :engine_version=>"1.4.14", :auto_minor_version_upgrade=>true, :preferred_maintenance_window=>"sat:18:00-sat:19:00", :client_download_landing_page=>"https://console.aws.amazon.com/elasticache/home#client-download:", :cache_subnet_group_name=>"yanase-cache-subnet-group", :num_cache_nodes=>1, :response_metadata=>{:request_id=>"481b4eca-7cda-11e2-b199-7f3c74a8d8c7"}} 
