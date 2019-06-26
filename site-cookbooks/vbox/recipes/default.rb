#
# Cookbook:: vbox
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package "kernel-devel" do
  action [ :install, :upgrade ]
  notifies :restart, "service[vboxadd-service]", :immediately
end

service "vboxadd-service" do
  action :start
end
