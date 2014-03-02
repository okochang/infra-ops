#
# Cookbook Name:: tempdir
# Recipe:: default
#
# Copyright 2013, @oko_chang
#
# All rights reserved - Do Not Redistribute
#
cookbook_file "/tmp/test.txt" do
  source "test.txt"
  mode 00644
  checksum "d262bcee23ba7de60f004fb345bd1ad6871f5e9748e5a1aa8a6370784b5e1f99"
end

directory "/tmp/var" do
  owner "ec2-user"
  user "ec2-user"
  mode "0775"
  action :create
end
