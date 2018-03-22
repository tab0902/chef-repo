#
# Cookbook:: remi
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

repository = node['remi']['repository']

remote_file "#{Chef::Config[:file_cache_path]}/#{repository}" do
  source "http://rpms.famillecollet.com/enterprise/#{repository}"
end

rpm_package "remi-release" do
  source "#{Chef::Config[:file_cache_path]}/#{repository}"
  action :install
end
