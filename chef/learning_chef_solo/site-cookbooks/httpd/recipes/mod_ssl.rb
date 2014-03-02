#
# Cookbook Name:: httpd
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
package "mod_ssl" do
  action :install
end

template "ssl.conf" do
  path "/etc/httpd/conf.d/ssl.conf"
  source "ssl.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, 'service[httpd]'
end

directory '/etc/httpd/ssl' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file "/etc/httpd/ssl/chef-solo.okochang.com.crt" do
  mode 0644
end

cookbook_file "/etc/httpd/ssl/chef-solo.okochang.com.key" do
  mode 0644
end
