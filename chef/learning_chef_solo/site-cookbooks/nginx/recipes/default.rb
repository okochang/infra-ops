#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2013, @okochang
#
# All rights reserved - Do Not Redistribute
#
package "nginx" do
  action :install
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

template "nginx.conf" do
  path "/etc/nginx/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, 'service[nginx]'
end

