#
# Cookbook:: epel
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package "epel-release" do
  action [ :install, :upgrade ]
end
