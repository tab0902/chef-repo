#
# Cookbook:: sshd
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

environment = node.chef_environment

data_bag = Chef::EncryptedDataBagItem.load('sshd','port')
port     = data_bag["#{environment}"]

execute 'disable_selinux' do
  user 'root'
  group 'root'
  not_if "grep -q 'Port #{port}' /etc/ssh/sshd_config"
  command <<-EOS
    cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.org
    sed -i -e "s/#Port 22/Port #{port}/g" /etc/ssh/sshd_config
  EOS
  notifies :restart, 'service[sshd]', :delayed
end

service 'sshd' do
  action :nothing
end
