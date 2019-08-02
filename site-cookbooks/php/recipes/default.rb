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

execute 'edit_php_ini' do
  user 'root'
  group 'root'
  not_if "grep -q 'mbstring.internal_encoding = #{encoding}' #{php_ini}"
  command <<-EOS
    cp -p #{php_ini} #{php_ini}.org
    sed -i -e "s/;date.timezone =/date.timezone = '#{timezone}'/g" #{php_ini}
    sed -i -e "s/;mbstring.language = Japanese/mbstring.language = #{language}/g" #{php_ini}
    sed -i -e "s/;mbstring.internal_encoding =/mbstring.internal_encoding = #{encoding}/g" #{php_ini}
    sed -i -e "s/;mbstring.http_input =/mbstring.http_input = #{encoding}/g" #{php_ini}
  EOS
  notifies :restart, 'service[httpd]', :delayed
end

if node['php']['packages'].include?("php-pecl-xdebug") then
  execute "add_settings_for_xdebug" do
    user "root"
    group "root"
    not_if "grep -q 'xdebug.coverage_enable=1' #{php_ini}"
    command <<-EOS
      echo 'xdebug.coverage_enable=1' >> #{php_ini}
      echo 'xdebug.default_enable=1' >> #{php_ini}
      echo 'xdebug.profiler_enable=1' >> #{php_ini}
      echo 'xdebug.profiler_output_dir="/tmp"' >> #{php_ini}
      echo 'xdebug.remote_autostart=1' >> #{php_ini}
      echo 'xdebug.remote_enable=1' >> #{php_ini}
      echo 'xdebug.remote_host=localhost' >> #{php_ini}
      echo 'xdebug.remote_port=9000' >> #{php_ini}
    EOS
  end
end
