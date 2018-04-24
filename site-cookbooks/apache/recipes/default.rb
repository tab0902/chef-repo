#
# Cookbook:: apache
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name  = node['user']['name']

%W{ httpd httpd-devel }.each do |item|
  package "#{item}" do
    action [ :install, :upgrade ]
  end
end

service 'httpd' do
  action [ :enable, :start ]
end

execute "chmod_home_dir" do
  user "#{user_name}"
  group "#{user_name}"
  not_if "test `stat -c '%a' /home/#{user_name}` -eq '755'"
  command <<-EOS
    chmod 755 /home/#{user_name}
  EOS
end
