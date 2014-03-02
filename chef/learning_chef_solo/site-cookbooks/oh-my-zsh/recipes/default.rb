#
# Cookbook Name:: oh-my-zsh
# Recipe:: default
#
# Copyright 2013, @oko_chang
#
# All rights reserved - Do Not Redistribute
#
directory '/home/ec2-user/.oh-my-zsh' do
  owner 'ec2-user'
  group 'ec2-user'
  mode '0755'
  action :create
end

git "/home/ec2-user/.oh-my-zsh" do
  repository "git://github.com/robbyrussell/oh-my-zsh.git"
  reference "master"
  action :export
  user "ec2-user"
  group "ec2-user"
end

