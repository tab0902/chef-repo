#
# Cookbook:: wkhtmltopdf
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

packages    = node['wkhtmltopdf']['packages']
version     = node['wkhtmltopdf']['version']
source_uri  = node['wkhtmltopdf']['source_uri']
install_dir = node['wkhtmltopdf']['install_dir']
user_name   = node['user']['name']

packages.each do |item|
  package "#{item}" do
    action [ :install, :upgrade ]
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/wkhtmltox-#{version}_linux-generic-amd64.tar.xz" do
  source "#{source_uri}"
end

execute "install_wkhtmltopdf" do
  user "root"
  group "root"
  not_if "find #{install_dir}/bin/wkhtmltopdf"
  command <<-EOS
    cd #{install_dir}/src
    tar Jxfv #{Chef::Config[:file_cache_path]}/wkhtmltox-#{version}_linux-generic-amd64.tar.xz
    sudo cp #{install_dir}/src/wkhtmltox/bin/wkhtmlto* #{install_dir}/bin
  EOS
end
