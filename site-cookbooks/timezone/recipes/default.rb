#
# Cookbook:: timezone
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

timezone = node['timezone']['name']

timezone "#{timezone}" do
  notifies :request_reboot, "reboot[to_reflect_timezone_setting]", :immediately
end

reboot "to_reflect_timezone_setting" do
  action :nothing
  delay_mins 1
  reason "To reflect timezone setting"
end
