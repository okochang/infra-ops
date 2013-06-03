# -*- coding: utf-8 -*- 
## VPCを作成して削除するまでの流れを記載したもので、スクリプトではないので注意して下さい
require 'aws-sdk'
ACCESS_KEY = 'set your access key'
SECRET_KEY = 'set your secret key'
EC2_REGION = 'ec2.ap-southeast-1.amazonaws.com'
 
ec2 = AWS::EC2.new(
  :access_key_id => ACCESS_KEY,
  :secret_access_key => SECRET_KEY,
  :ec2_endpoint => EC2_REGION
).client

vpc_cidr = '10.0.0.0/16'
subnet_a = '10.0.1.0/24'
subnet_b = '10.0.2.0/24'

## VPCのCIDRを作成します
ec2.create_vpc(:cidr_block => vpc_cidr, :instance_tenancy => 'default')
 => {:request_id=>"afcd2cd2-07ce-4714-858b-2e45c800d514", :vpc=>{:tag_set=>[], :vpc_id=>"vpc-662d2c0f", :state=>"pending", :cidr_block=>"10.0.0.0/16", :dhcp_options_id=>"dopt-7a2d2c13", :instance_tenancy=>"default"}} 

## デフォルトでルートテーブルが割り当てられます
ec2.describe_route_tables[:route_table_set]
 => [{:route_set=>[{:destination_cidr_block=>"10.0.0.0/16", :gateway_id=>"local", :state=>"active", :origin=>"CreateRouteTable"}], :association_set=>[{:route_table_association_id=>"rtbassoc-7b2d2c12", :route_table_id=>"rtb-782d2c11", :main=>true}], :tag_set=>[], :propagating_vgw_set=>[], :route_table_id=>"rtb-782d2c11", :vpc_id=>"vpc-662d2c0f"}] 

## DHCPオプションもVPC作成時に割り当てられます
ec2.describe_dhcp_options[:dhcp_options_set]
 => [{:dhcp_configuration_set=>[{:value_set=>[{:value=>"ap-southeast-1.compute.internal"}], :key=>"domain-name"}, {:value_set=>[{:value=>"AmazonProvidedDNS"}], :key=>"domain-name-servers"}], :tag_set=>[], :dhcp_options_id=>"dopt-7a2d2c13"}] 

## Internet Gatewayを作成します
ec2.create_internet_gateway
 => {:request_id=>"e0566f87-112e-4a2b-b656-c551f140b1b8", :internet_gateway=>{:attachment_set=>[], :tag_set=>[], :internet_gateway_id=>"igw-902f2ef9"}} 

## 作成したInternet GatewayをVPCにアタッチします
ec2.attach_internet_gateway(:internet_gateway_id => 'igw-902f2ef9', :vpc_id => 'vpc-662d2c0f')

ec2.describe_internet_gateways[:internet_gateway_set]
 => [{:attachment_set=>[{:vpc_id=>"vpc-662d2c0f", :state=>"available"}], :tag_set=>[], :internet_gateway_id=>"igw-902f2ef9"}] 

## Virtual Private Gatewayを作成します
ec2.create_vpn_gateway(:type => 'ipsec.1')
 => {:request_id=>"0130f8ef-0042-4a32-b181-e94ed82217c8", :vpn_gateway=>{:attachments=>[], :tag_set=>[], :vpn_gateway_id=>"vgw-19fe874b", :state=>"available", :vpn_type=>"ipsec.1"}} 

## 作成したVirtual Private GatewayをVPCにアタッチします
ec2.attach_vpn_gateway(:vpn_gateway_id => 'vgw-19fe874b', :vpc_id => 'vpc-662d2c0f')
 => {:request_id=>"1cbea21e-e95c-46d6-8e45-a353bbfef299", :attachment=>{:vpc_id=>"vpc-662d2c0f", :state=>"attaching"}} 

ec2.describe_vpn_gateways[:vpn_gateway_set]
 => [{:attachments=>[{:vpc_id=>"vpc-662d2c0f", :state=>"attached"}], :tag_set=>[], :vpn_gateway_id=>"vgw-19fe874b", :state=>"available", :vpn_type=>"ipsec.1"}] 

## VPC内にサブネットを作成します
ec2.create_subnet(:vpc_id => 'vpc-662d2c0f', :cidr_block => subnet_a, :availability_zone => 'ap-southeast-1a')
 => {:request_id=>"0d11707d-c80e-4e38-8713-57c7caffc63e", :subnet=>{:tag_set=>[], :subnet_id=>"subnet-6739380e", :state=>"pending", :vpc_id=>"vpc-662d2c0f", :cidr_block=>"10.0.1.0/24", :available_ip_address_count=>251, :availability_zone=>"ap-southeast-1a"}} 

ec2.create_subnet(:vpc_id => 'vpc-662d2c0f', :cidr_block => subnet_b, :availability_zone => 'ap-southeast-1b')
 => {:request_id=>"bcb39593-30b9-489a-ad02-5268314402b7", :subnet=>{:tag_set=>[], :subnet_id=>"subnet-fa393893", :state=>"pending", :vpc_id=>"vpc-662d2c0f", :cidr_block=>"10.0.2.0/24", :available_ip_address_count=>251, :availability_zone=>"ap-southeast-1b"}} 

ec2.describe_subnets[:subnet_set]
 => [{:tag_set=>[], :subnet_id=>"subnet-fa393893", :state=>"available", :vpc_id=>"vpc-662d2c0f", :cidr_block=>"10.0.2.0/24", :available_ip_address_count=>251, :availability_zone=>"ap-southeast-1b", :default_for_az=>false, :map_public_ip_on_launch=>false}, {:tag_set=>[], :subnet_id=>"subnet-6739380e", :state=>"available", :vpc_id=>"vpc-662d2c0f", :cidr_block=>"10.0.1.0/24", :available_ip_address_count=>251, :availability_zone=>"ap-southeast-1a", :default_for_az=>false, :map_public_ip_on_launch=>false}] 

## Iternet Gatewayを割り当てるRoute Tableを作成する
ec2.create_route_table(:vpc_id => 'vpc-662d2c0f')
 => {:request_id=>"87a8f5ae-0f45-4249-83a5-7e998fdaafbe", :route_table=>{:route_set=>[{:destination_cidr_block=>"10.0.0.0/16", :gateway_id=>"local", :state=>"active", :origin=>"CreateRouteTable"}], :association_set=>[], :tag_set=>[], :propagating_vgw_set=>[], :route_table_id=>"rtb-41383928", :vpc_id=>"vpc-662d2c0f"}} 

## 作成したRoute TableにInternet Gatewayへの経路を追加する
ec2.create_route(:route_table_id => 'rtb-41383928', :destination_cidr_block => '0.0.0.0/0', :gateway_id => 'igw-902f2ef9')
 => {:request_id=>"f5f4b43b-7714-4299-a6c1-413bb603ebd4", :return=>"true"} 

## Virtual Private Gatewayを割り当てるRoute Tableを作成する
ec2.create_route_table(:vpc_id => 'vpc-662d2c0f')
 => {:request_id=>"9c0273e1-a245-4440-ad14-052ca5782967", :route_table=>{:route_set=>[{:destination_cidr_block=>"10.0.0.0/16", :gateway_id=>"local", :state=>"active", :origin=>"CreateRouteTable"}], :association_set=>[], :tag_set=>[], :propagating_vgw_set=>[], :route_table_id=>"rtb-163b3a7f", :vpc_id=>"vpc-662d2c0f"}}

## 作成したRoute TableにVirtual Private Gatewayへの経路を追加する
ec2.create_route(:route_table_id => 'rtb-163b3a7f', :destination_cidr_block => '0.0.0.0/0', :gateway_id => 'vgw-19fe874b')
 => {:request_id=>"fe1570c9-3634-4fc1-8f2f-e528e5e32246", :return=>"true"} 

## 作成したRoute Tableにサブネットを割り当てる
ec2.associate_route_table(:subnet_id => 'subnet-6739380e', :route_table_id => 'rtb-41383928')
 => {:request_id=>"f2cb7d96-f3aa-4582-90cb-4167411d0c27", :association_id=>"rtbassoc-aa3a3bc3"} 

ec2.associate_route_table(:subnet_id => 'subnet-fa393893', :route_table_id => 'rtb-163b3a7f')
 => {:request_id=>"92e70844-91bf-4b9d-96f1-dc1e9ab78d0b", :association_id=>"rtbassoc-3b3d3c52"} 

## 作成したRoute Tableを表示する
ec2.describe_route_tables(:route_table_ids => ['rtb-41383928'])[:route_table_set]
 => [{:route_set=>[{:destination_cidr_block=>"10.0.0.0/16", :gateway_id=>"local", :state=>"active", :origin=>"CreateRouteTable"}, {:destination_cidr_block=>"0.0.0.0/0", :gateway_id=>"igw-902f2ef9", :state=>"active", :origin=>"CreateRoute"}], :association_set=>[{:route_table_association_id=>"rtbassoc-aa3a3bc3", :route_table_id=>"rtb-41383928", :subnet_id=>"subnet-6739380e"}], :tag_set=>[], :propagating_vgw_set=>[], :route_table_id=>"rtb-41383928", :vpc_id=>"vpc-662d2c0f"}] 

ec2.describe_route_tables(:route_table_ids => ['rtb-163b3a7f'])[:route_table_set]
 => [{:route_set=>[{:destination_cidr_block=>"10.0.0.0/16", :gateway_id=>"local", :state=>"active", :origin=>"CreateRouteTable"}, {:destination_cidr_block=>"0.0.0.0/0", :gateway_id=>"vgw-19fe874b", :state=>"active", :origin=>"CreateRoute"}], :association_set=>[{:route_table_association_id=>"rtbassoc-3b3d3c52", :route_table_id=>"rtb-163b3a7f", :subnet_id=>"subnet-fa393893"}], :tag_set=>[], :propagating_vgw_set=>[], :route_table_id=>"rtb-163b3a7f", :vpc_id=>"vpc-662d2c0f"}] 

## サブネットを削除します
ec2.delete_subnet(:subnet_id => 'subnet-6739380e')
 => {:request_id=>"54c8d802-a653-485b-9904-6e19a9373345", :return=>"true"} 

ec2.delete_subnet(:subnet_id => 'subnet-fa393893')
 => {:request_id=>"ac064d7a-0179-42b4-9038-6ea0f1dc9eb2", :return=>"true"} 

## Route Tableを削除します
ec2.delete_route_table(:route_table_id => 'rtb-41383928')
 => {:request_id=>"5486f4ca-8b92-477c-bf2d-d0f2884b64ff", :return=>"true"} 

ec2.delete_route_table(:route_table_id => 'rtb-163b3a7f')
 => {:request_id=>"34e88a88-545c-4eed-b526-df217d599121", :return=>"true"} 

## Internet GatewayとVirtual Private Gatewayをデタッチします
ec2.detach_internet_gateway(:internet_gateway_id => 'igw-902f2ef9', :vpc_id => 'vpc-662d2c0f')
 => {:request_id=>"009c2b31-085e-414d-9d8a-4796604c717b", :return=>"true"} 

ec2.detach_vpn_gateway(:vpn_gateway_id => 'vgw-19fe874b', :vpc_id => 'vpc-662d2c0f')
 => {:request_id=>"f86ccba7-ba46-4c99-b91c-19cd49da0c90", :return=>"true"} 

## Internet GatewayとVirtual Private Gatewayを削除します
ec2.delete_internet_gateway(:internet_gateway_id => 'igw-902f2ef9')
 => {:request_id=>"8592a0bc-dedb-4227-bb0f-54319fec14a6", :return=>"true"} 

ec2.delete_vpn_gateway(:vpn_gateway_id => 'vgw-19fe874b')
 => {:request_id=>"84e07fff-f12c-448b-86ea-9be45e955599", :return=>"true"} 

## VPCを削除します
ec2.delete_vpc(:vpc_id => 'vpc-662d2c0f')
 => {:request_id=>"1365199a-9b58-4344-b8a7-1bb16e025961", :return=>"true"} 
