#
# Cookbook:: apache
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

%W{ httpd httpd-devel }.each do |item|
  package "#{item}" do
    action [ :install, :upgrade ]
  end
end

service 'httpd' do
  action [ :enable, :start ]
end
