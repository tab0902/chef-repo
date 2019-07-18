#
# Cookbook:: php
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

version  = node['php']['version']
packages = node['php']['packages']
php_ini  = node['php']['ini']
timezone = node['php']['timezone']
language = node['php']['language']
encoding = node['php']['encoding']
xdebug   = node['php']['xdebug']

packages.each do |item|
  package "#{item}" do
    action [ :install, :upgrade ]
    options "--enablerepo=remi,remi-php#{version}"
  end
end

template "#{php_ini}" do
  owner "root"
  group "root"
  mode 0644
  source 'php.ini.erb'
  notifies :restart, 'service[httpd]', :delayed
  variables({
    :timezone => timezone,
    :language => language,
    :encoding => encoding,
    :xdebug => xdebug,
  })
end
