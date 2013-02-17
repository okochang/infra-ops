# -*- coding: utf-8 -*-
require 'aws-sdk'

ACCESS_KEY = "set your access key id"
SECRET_KEY = "set your secret key"
REGION = 'redshift.us-east-1.amazonaws.com'
EC2_REGION = 'ec2.us-east-1.amazonaws.com'

## Redshift用のインターフェースを作成します
rs = AWS::Redshift.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :redshift_endpoint => REGION
).client

## VPCの場合はセキュリティグループなどがVPCのものと統合されるので、こちらもインターフェースを作成します
ec2 = AWS::EC2.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :redshift_endpoint => EC2_REGION
).client

## VPC内でクラスタを作る場合は、サブネットグループが必要です
rs.create_cluster_subnet_group(:cluster_subnet_group_name => "yanase-subnet-group", :description => "20130217", :subnet_ids => ["subnet-eca2ca81", "subnet-45a2ca28"])
 => {:subnets=>[{:subnet_status=>"Active", :subnet_identifier=>"subnet-eca2ca81", :subnet_availability_zone=>{:name=>"us-east-1b"}}, {:subnet_status=>"Active", :subnet_identifier=>"subnet-45a2ca28", :subnet_availability_zone=>{:name=>"us-east-1a"}}], :vpc_id=>"vpc-4ca2ca21", :description=>"20130217", :cluster_subnet_group_name=>"yanase-subnet-group", :subnet_group_status=>"Complete", :response_metadata=>{:request_id=>"dbc147fe-78bf-11e2-9801-7f311a0d4866"}}

## Redshift用にVPCのセキュリティグループを作ります
ec2.create_security_group(:group_name => "yanase-redshift-security-group", :description => "20130217", :vpc_id => "vpc-4ca2ca21")
 => {:request_id=>"54bdb08e-f907-47c8-9614-029bf0b290aa", :return=>"true", :group_id=>"sg-da8b76b5"} 

## 作成したセキュリティグループに接続許可のルールを作ります
ec2.authorize_security_group_ingress(:group_id => "sg-da8b76b5", :ip_protocol => "tcp", :to_port => 5439, :cidr_ip => "107.23.100.53/32")
 => {:request_id=>"77e635cf-ecb3-4ce4-a083-5173f74efcda", :return=>"true"} 

## パラメータグループを作ります
rs.create_cluster_parameter_group(:parameter_group_name => "yanase-parameter-group", :description => "20130217", :parameter_group_family => "redshift-1.0")
 => {:parameter_group_family=>"redshift-1.0", :description=>"20130217", :parameter_group_name=>"yanase-parameter-group", :response_metadata=>{:request_id=>"4a055c93-78c2-11e2-a353-5fb4a4ddc875"}} 

## Redshiftのクラスタを作ります
rs.create_cluster(
:cluster_identifier => "yanase-redshift-cluster", 
:db_name => "yanasedb", :node_type => "dw.hs1.xlarge", 
:cluster_type => "multi-node", 
:master_username => "root", 
:master_user_password => "4xU9FdZGV4", 
:vpc_security_group_ids => ["sg-da8b76b5"], 
:cluster_subnet_group_name => "yanase-subnet-group", 
:availability_zone => "us-east-1a", 
:preferred_maintenance_window => "Sun:06:00-Sun:07:00", 
:cluster_parameter_group_name => "yanase-parameter-group", 
:automated_snapshot_retention_period => 5, 
:port => 5439, :cluster_version => "1.0", 
:allow_version_upgrade => true, 
:number_of_nodes => 2
)
 => {:cluster_security_groups=>[], :vpc_security_groups=>[{:status=>"active", :vpc_security_group_id=>"sg-da8b76b5"}], :cluster_parameter_groups=>[{:parameter_apply_status=>"in-sync", :parameter_group_name=>"yanase-parameter-group"}], :pending_modified_values=>{:master_user_password=>"****"}, :cluster_subnet_group_name=>"yanase-subnet-group", :cluster_version=>"1.0", :cluster_status=>"creating", :encrypted=>"false", :number_of_nodes=>2, :publicly_accessible=>false, :automated_snapshot_retention_period=>5, :db_name=>"yanasedb", :preferred_maintenance_window=>"sun:06:00-sun:07:00", :vpc_id=>"vpc-4ca2ca21", :availability_zone=>"us-east-1a", :node_type=>"dw.hs1.xlarge", :cluster_identifier=>"yanase-redshift-cluster", :allow_version_upgrade=>true, :master_username=>"root", :response_metadata=>{:request_id=>"a897a90c-78c8-11e2-8a94-97d34e3faa7d"}} 

## 作成されたRedsfihtのクラスタを参照します
rs.describe_clusters[:clusters]
 => [{:cluster_security_groups=>[{:status=>"active", :cluster_security_group_name=>"yanase-security-group"}], :vpc_security_groups=>[], :cluster_parameter_groups=>[{:parameter_apply_status=>"in-sync", :parameter_group_name=>"yanase-parameter-group"}], :pending_modified_values=>nil, :cluster_version=>"1.0", :endpoint=>{:port=>5439, :address=>"okochang-redshift-cluster.cywwc1kjl4di.us-east-1.redshift.amazonaws.com"}, :cluster_status=>"available", :encrypted=>"false", :number_of_nodes=>1, :publicly_accessible=>true, :automated_snapshot_retention_period=>5, :db_name=>"okochangdb", :preferred_maintenance_window=>"sun:06:00-sun:07:00", :cluster_create_time=>2013-02-17 06:27:30 UTC, :availability_zone=>"us-east-1a", :node_type=>"dw.hs1.xlarge", :cluster_identifier=>"okochang-redshift-cluster", :allow_version_upgrade=>true, :master_username=>"root"}, {:cluster_security_groups=>[], :vpc_security_groups=>[{:status=>"active", :vpc_security_group_id=>"sg-da8b76b5"}], :cluster_parameter_groups=>[{:parameter_apply_status=>"in-sync", :parameter_group_name=>"yanase-parameter-group"}], :pending_modified_values=>nil, :cluster_subnet_group_name=>"yanase-subnet-group", :cluster_version=>"1.0", :endpoint=>{:port=>5439, :address=>"yanase-redshift-cluster.cywwc1kjl4di.us-east-1.redshift.amazonaws.com"}, :cluster_status=>"available", :encrypted=>"false", :number_of_nodes=>2, :publicly_accessible=>false, :automated_snapshot_retention_period=>5, :db_name=>"yanasedb", :preferred_maintenance_window=>"sun:06:00-sun:07:00", :vpc_id=>"vpc-4ca2ca21", :cluster_create_time=>2013-02-17 06:24:55 UTC, :availability_zone=>"us-east-1a", :node_type=>"dw.hs1.xlarge", :cluster_identifier=>"yanase-redshift-cluster", :allow_version_upgrade=>true, :master_username=>"root"}] 

## 動作確認が終わったらきちんと削除しましょう
rs.delete_cluster(:cluster_identifier => "yanase-redshift-cluster", :skip_final_cluster_snapshot => true)
 => {:cluster_security_groups=>[], :vpc_security_groups=>[{:status=>"active", :vpc_security_group_id=>"sg-da8b76b5"}], :cluster_parameter_groups=>[{:parameter_apply_status=>"in-sync", :parameter_group_name=>"yanase-parameter-group"}], :pending_modified_values=>nil, :cluster_subnet_group_name=>"yanase-subnet-group", :cluster_version=>"1.0", :endpoint=>{:port=>5439, :address=>"yanase-redshift-cluster.cywwc1kjl4di.us-east-1.redshift.amazonaws.com"}, :cluster_status=>"deleting", :encrypted=>"false", :number_of_nodes=>2, :publicly_accessible=>false, :automated_snapshot_retention_period=>5, :db_name=>"yanasedb", :preferred_maintenance_window=>"sun:06:00-sun:07:00", :vpc_id=>"vpc-4ca2ca21", :cluster_create_time=>2013-02-17 06:24:55 UTC, :availability_zone=>"us-east-1a", :node_type=>"dw.hs1.xlarge", :cluster_identifier=>"yanase-redshift-cluster", :allow_version_upgrade=>true, :master_username=>"root", :response_metadata=>{:request_id=>"11b0f7f3-78cf-11e2-b321-8156d8957973"}} 
