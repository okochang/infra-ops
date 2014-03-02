#
# Cookbook Name:: perlbrew
# Recipe:: default
#
# Copyright 2013, @oko_chang
#
# All rights reserved - Do Not Redistribute
#
bash "install perlbrew" do
  user node['user']['name']
  group node['group']['name']
  cwd "/home/#{node['user']['name']}"
  environment "HOME" => "/home/#{node['user']['name']}"
  code <<-EOC
    curl -kL http://install.perlbrew.pl | bash
  EOC
  creates "/home/#{node['user']['name']}/perl5/perlbrew/bin/perlbrew"
end
