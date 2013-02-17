# -*- coding: utf-8 -*-
require 'aws-sdk'

ACCESS_KEY = "set your access key id"
SECRET_KEY = "set your secret key"
REGION = 'redshift.us-east-1.amazonaws.com'

## Redshift用にログイン
rs = AWS::Redshift.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :redshift_endpoint => REGION
).client

## セキュリティグループを作ります
rs.create_cluster_security_group(:cluster_security_group_name => "yanase-security-group", :description => "20130217")
 => {:ec2_security_groups=>[], :ip_ranges=>[], :description=>"20130217", :cluster_security_group_name=>"yanase-security-group", :response_metadata=>{:request_id=>"af6e7887-78c1-11e2-bedb-2d856ff57bc9"}} 

## 先ほど作成したセキュリティグループにルールを追加します
rs.authorize_cluster_security_group_ingress(:cluster_security_group_name => "yanase-security-group", :cidrip => "107.23.100.53/32")
 => {:ec2_security_groups=>[], :ip_ranges=>[{:cidrip=>"107.23.100.53/32", :status=>"authorized"}], :description=>"20130217", :cluster_security_group_name=>"yanase-security-group", :response_metadata=>{:request_id=>"a01944ef-78cf-11e2-a353-5fb4a4ddc875"}} 

## パラメータグループを作ります
rs.create_cluster_parameter_group(:parameter_group_name => "yanase-parameter-group", :description => "20130217", :parameter_group_family => "redshift-1.0")
 => {:parameter_group_family=>"redshift-1.0", :description=>"20130217", :parameter_group_name=>"yanase-parameter-group", :response_metadata=>{:request_id=>"4a055c93-78c2-11e2-a353-5fb4a4ddc875"}} 

## Redshiftのクラスタを作ります
rs.create_cluster(
:cluster_identifier => "okochang-redshift-cluster", 
:db_name => "okochangdb", 
:node_type => "dw.hs1.xlarge", 
:cluster_type => "single-node", 
:master_username => "root", 
:master_user_password => "4xU9FdZGV4", 
:cluster_security_groups => ["yanase-security-group"], 
:availability_zone => "us-east-1a", 
:preferred_maintenance_window => "Sun:06:00-Sun:07:00", 
:cluster_parameter_group_name => "yanase-parameter-group", 
:automated_snapshot_retention_period => 5, 
:port => 5439, 
:cluster_version => "1.0", 
:allow_version_upgrade => true
)
 => {:cluster_security_groups=>[{:status=>"active", :cluster_security_group_name=>"yanase-security-group"}], :vpc_security_groups=>[], :cluster_parameter_groups=>[{:parameter_apply_status=>"in-sync", :parameter_group_name=>"yanase-parameter-group"}], :pending_modified_values=>{:master_user_password=>"****"}, :cluster_version=>"1.0", :cluster_status=>"creating", :encrypted=>"false", :number_of_nodes=>1, :publicly_accessible=>true, :automated_snapshot_retention_period=>5, :db_name=>"okochangdb", :preferred_maintenance_window=>"sun:06:00-sun:07:00", :availability_zone=>"us-east-1a", :node_type=>"dw.hs1.xlarge", :cluster_identifier=>"okochang-redshift-cluster", :allow_version_upgrade=>true, :master_username=>"root", :response_metadata=>{:request_id=>"b8c23198-78c9-11e2-b45e-afab3dfc8c01"}} 

## 作成されたRedsfihtのクラスタを参照します
rs.describe_clusters[:clusters]
 => [{:cluster_security_groups=>[{:status=>"active", :cluster_security_group_name=>"yanase-security-group"}], :vpc_security_groups=>[], :cluster_parameter_groups=>[{:parameter_apply_status=>"in-sync", :parameter_group_name=>"yanase-parameter-group"}], :pending_modified_values=>nil, :cluster_version=>"1.0", :endpoint=>{:port=>5439, :address=>"okochang-redshift-cluster.cywwc1kjl4di.us-east-1.redshift.amazonaws.com"}, :cluster_status=>"available", :encrypted=>"false", :number_of_nodes=>1, :publicly_accessible=>true, :automated_snapshot_retention_period=>5, :db_name=>"okochangdb", :preferred_maintenance_window=>"sun:06:00-sun:07:00", :cluster_create_time=>2013-02-17 06:27:30 UTC, :availability_zone=>"us-east-1a", :node_type=>"dw.hs1.xlarge", :cluster_identifier=>"okochang-redshift-cluster", :allow_version_upgrade=>true, :master_username=>"root"}, {:cluster_security_groups=>[], :vpc_security_groups=>[{:status=>"active", :vpc_security_group_id=>"sg-da8b76b5"}], :cluster_parameter_groups=>[{:parameter_apply_status=>"in-sync", :parameter_group_name=>"yanase-parameter-group"}], :pending_modified_values=>nil, :cluster_subnet_group_name=>"yanase-subnet-group", :cluster_version=>"1.0", :endpoint=>{:port=>5439, :address=>"yanase-redshift-cluster.cywwc1kjl4di.us-east-1.redshift.amazonaws.com"}, :cluster_status=>"available", :encrypted=>"false", :number_of_nodes=>2, :publicly_accessible=>false, :automated_snapshot_retention_period=>5, :db_name=>"yanasedb", :preferred_maintenance_window=>"sun:06:00-sun:07:00", :vpc_id=>"vpc-4ca2ca21", :cluster_create_time=>2013-02-17 06:24:55 UTC, :availability_zone=>"us-east-1a", :node_type=>"dw.hs1.xlarge", :cluster_identifier=>"yanase-redshift-cluster", :allow_version_upgrade=>true, :master_username=>"root"}] 

## 動作確認が終わったらきちんと削除しましょう
rs.delete_cluster(:cluster_identifier => "okochang-redshift-cluster", :skip_final_cluster_snapshot => true)
 => {:cluster_security_groups=>[{:status=>"active", :cluster_security_group_name=>"yanase-security-group"}], :vpc_security_groups=>[], :cluster_parameter_groups=>[{:parameter_apply_status=>"in-sync", :parameter_group_name=>"yanase-parameter-group"}], :pending_modified_values=>nil, :cluster_version=>"1.0", :endpoint=>{:port=>5439, :address=>"okochang-redshift-cluster.cywwc1kjl4di.us-east-1.redshift.amazonaws.com"}, :cluster_status=>"deleting", :encrypted=>"false", :number_of_nodes=>1, :publicly_accessible=>true, :automated_snapshot_retention_period=>5, :db_name=>"okochangdb", :preferred_maintenance_window=>"sun:06:00-sun:07:00", :cluster_create_time=>2013-02-17 06:27:30 UTC, :availability_zone=>"us-east-1a", :node_type=>"dw.hs1.xlarge", :cluster_identifier=>"okochang-redshift-cluster", :allow_version_upgrade=>true, :master_username=>"root", :response_metadata=>{:request_id=>"187880ac-78cf-11e2-a353-5fb4a4ddc875"}} 
