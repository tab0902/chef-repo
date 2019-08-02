#
# Cookbook:: wordpress
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name  = node['user']['name']
db_host    = node['mysql']['db_host']
charset    = node['mysql']['config']['charset']
collate    = node['mysql']['config']['collate']
repository = node['wordpress']['repository']
db_name    = node["wordpress"]["db_name"]
environment = node.chef_environment

wordpress = "/home/#{user_name}/wordpress"

remote_file "/home/#{user_name}/#{repository}" do
  owner "#{user_name}"
  group "#{user_name}"
  mode 0644
  source "http://ja.wordpress.org/#{repository}"
end

execute "unzip_wordpress" do
  user "#{user_name}"
  group "#{user_name}"
  cwd "/home/#{user_name}"
  not_if "find #{wordpress}"
  command <<-EOS
    tar xfz /home/#{user_name}/#{repository}
  EOS
end

execute "chmod_wp-content" do
  user "#{user_name}"
  group "#{user_name}"
  not_if "test `stat -c '%a' /home/#{user_name}/wordpress/wp-content` -eq '777'"
  command <<-EOS
    chmod -R 777 /home/#{user_name}/wordpress/wp-content
  EOS
end

file "/home/#{user_name}/#{repository}" do
  action :delete
end

data_bag = Chef::EncryptedDataBagItem.load('passwords','mysql')
password = data_bag["#{environment}"]

template "#{wordpress}/wp-config.php" do
  owner "#{user_name}"
  group "#{user_name}"
  mode 0644
  source "wp-config.php.erb"
  action :create_if_missing
  variables({
    :db_name => db_name,
    :user_name => user_name,
    :password => password,
    :db_host => db_host,
    :charset => charset,
    :collate => collate
  })
end
