#
# Cookbook Name:: php
# Recipe:: default
#
# Copyright 2013, @oko_chang
#
# All rights reserved - Do Not Redistribute
#

%w{php php-common php-cli php-dba php-devel php-fpm php-gd php-imap php-mcrypt php-mysql php-odbc php-pdo php-pear php-pecl-apc php-pgsql php-soap php-xml}.each do |pkg|
  package pkg do
    action :install
  end
end

template "php.ini" do
  path "/etc/php.ini"
  source "php.ini.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, 'service[httpd]'
end
