#
# Cookbook Name:: zabbix-agent
# Recipe:: default
#
# Copyright 2013, Serverworks
#
# All rights reserved - Do Not Redistribute
#
centos_rpm = "zabbix-release-2.0-1.el6.noarch.rpm"

case node['platform']
when "amazon"
  template "serverworks-zabbix.repo" do
    path "/etc/yum.repos.d/serverworks-zabbix.repo"
    source "serverworks-zabbix.repo.erb"
    owner "root"
    group "root"
    mode 0644
  end
when "centos"
  cookbook_file "/tmp/#{centos_rpm}" do
    mode 00644
    checksum "d2c7f0dff751f6bfd9d1e8079f2f36b2ee1d683dc765d8384375b1f1cd30748c"
  end
  package "zabbix-release" do
    action :install
    source "/tmp/#{centos_rpm}"
  end
end

package "zabbix-agent" do
  action :install
end

service "zabbix-agent" do
  supports :status => true, :restart => true
  action [:enable, :start]
end

template "zabbix_agentd.conf" do
  path "/etc/zabbix/zabbix_agentd.conf"
  source "zabbix_agentd.conf.erb"
  owner "root"
  group "root"
  notifies :restart, 'service[zabbix-agent]'
end
