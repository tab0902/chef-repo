#
# Cookbook:: ntpd
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

package "ntp" do
  action [ :install, :upgrade ]
end

service 'ntpd' do
  action [ :enable, :start ]
end
