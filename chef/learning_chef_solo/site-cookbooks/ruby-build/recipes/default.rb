#
# Cookbook Name:: ruby-build
# Recipe:: default
#
# Copyright 2013, @oko_chang
#
# All rights reserved - Do Not Redistribute
#
git "/tmp/ruby-build" do
  user node['user']['name']
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :checkout
end

bash "install-rubybuild" do
  not_if 'which ruby-build'
  code <<-EOC
    cd /tmp/ruby-build
    ./install.sh
  EOC
end
