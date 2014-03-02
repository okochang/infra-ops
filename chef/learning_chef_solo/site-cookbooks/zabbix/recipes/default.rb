#
# Cookbook Name:: zabbix
# Recipe:: default
#
# Copyright 2013, @oko_chang
#
# All rights reserved - Do Not Redistribute
#
rpmfile = "zabbix-2.0.4-1.amzn1.x86_64.rpm"

cookbook_file "/tmp/#{rpmfile}" do
  mode 00644
  checksum "ebe98bca5221ec1322f09ecc078ab51dbc1d36241f357181ba535cf523c68b63"
end

package "zabbix" do
  action :install
  source "/tmp/#{rpmfile}"
end
