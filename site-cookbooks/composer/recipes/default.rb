#
# Cookbook:: composer
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

execute 'install_composer' do
  user 'root'
  group 'root'
  cwd "#{Chef::Config[:file_cache_path]}"
  not_if "find /usr/local/bin/composer"
  command <<-EOH
    curl -sS https://getcomposer.org/installer | php -- --install-dir=#{Chef::Config[:file_cache_path]}
    mv /#{Chef::Config[:file_cache_path]}/composer.phar /usr/local/bin/composer
  EOH
end
