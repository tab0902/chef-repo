#
# Cookbook:: user
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name = node["user"]["name"]

user "#{user_name}" do
  password "$1$2xEr4DS0$fpdwfH9GvdmZ2EHwZK5zZ1"
  home "/home/#{user_name}"
  manage_home true
end

group 'wheel' do
  action :modify
  members ["#{user_name}"]
  append true
end

file '/etc/sudoers' do
  _file = Chef::Util::FileEdit.new(path)
  _file.search_file_replace_line(
    /(NOPASSWD: ALL)$/,
    "%wheel	ALL=(ALL)	NOPASSWD: ALL\n"
  )
  content _file.send(:editor).lines.join
end
