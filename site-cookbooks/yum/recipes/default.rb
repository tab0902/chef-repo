#
# Cookbook:: yum
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package "yum-fastestmirror" do
  action [ :install, :upgrade ]
end

execute "yum-update" do
  user "root"
  group "root"
  command "yum -y update"
end
