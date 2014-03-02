#
# Cookbook Name:: user_group
# Recipe:: default
#
# Copyright 2013, @oko_chang
#
# All rights reserved - Do Not Redistribute
#
user "okochang" do
  comment "administrator"
  home "/home/okochang"
  shell "/bin/bash"
  password nil
  supports :manage_home => true
end

group "administrator" do
  gid 999
  members ['ec2-user', 'okochang']
  action :create
end

