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
  notifies :run, "execute[chmod_home_dir]", :immediately
end

execute "chmod_home_dir" do
  action :nothing
  user "#{user_name}"
  group "#{user_name}"
  command <<-EOS
    chmod 755 /home/#{user_name}
  EOS
end
