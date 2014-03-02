#
# Cookbook Name:: swapfile
# Recipe:: default
#
# Copyright 2013, @oko_chang
#
# All rights reserved - Do Not Redistribute
#
bash 'create swapfile' do
  code <<-EOC
    dd if=/dev/zero of=/swap.img bs=1M count=2048 &&
    chmod 600 /swap.img
    mkswap /swap.img
  EOC
  only_if { not node[:ec2].nil? and node[:ec2][:instances_type] == 't1.micro' }
  creates "/swap.img"
end

mount '/dev/null' do # swap file entry for fstab
  action :enable # cannot mount; only add to fstab
  device '/swap.img'
  fstype 'swap'
  only_if { not node[:ec2].nil? and node[:ec2][:instance_type] == 't1.micro' }
end

bash 'active swap' do
  code 'swapon -ae'
  only_if "test `cat /proc/swaps | wc -l` -eq 1"
end
