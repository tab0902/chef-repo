#
# Cookbook:: vbox
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package "kernel-devel" do
  action [ :install, :upgrade ]
  notifies :restart, "service[vboxadd-service]", :immediately
  notifies :run, "execute[set_timezone]", :immediately
end

service "vboxadd-service" do
  action :nothing
end

execute "set_timezone" do
  action :nothing
  user "root"
  group "root"
  command "cp /usr/share/zoneinfo/Japan /etc/localtime"
end
