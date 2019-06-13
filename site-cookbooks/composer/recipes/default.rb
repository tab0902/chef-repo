#
# Cookbook:: composer
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

source_uri  = node['composer']['install_dir']
install_dir = node['composer']['install_dir']
file_name   = node['composer']['file_name']

%W{ zip unzip }.each do |item|
  package "#{item}" do
    action [ :install, :upgrade ]
  end
end

execute 'install_composer' do
  user 'root'
  group 'root'
  cwd "#{Chef::Config[:file_cache_path]}"
  not_if "find #{install_dir}/#{file_name}"
  command <<-EOH
    curl -sS #{source_uri} | php -- --install-dir=#{Chef::Config[:file_cache_path]}
    mv /#{Chef::Config[:file_cache_path]}/composer.phar #{install_dir}/#{file_name}
  EOH
end
