#
# Cookbook:: wordpress
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name  = node['user']['name']
db_name    = node['mysql']['db_name']
db_host    = node['mysql']['db_host']
charset    = node['mysql']['charset']
repository = node['wordpress']['repository']
httpd_conf = node['wordpress']['httpd_conf']

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

data_bag = Chef::EncryptedDataBagItem.load('passwords','mysql')
password = data_bag["#{db_name}"]

template "#{wordpress}/wp-config.php" do
  owner "#{user_name}"
  group "#{user_name}"
  mode 0644
  source "wp-config.php.erb"
  variables({
    :db_name => db_name,
    :user_name => user_name,
    :password => password,
    :db_host => db_host,
    :charset => charset
  })
end

template "#{httpd_conf}" do
  owner "root"
  group "root"
  mode 0644
  source "httpd.conf.erb"
  notifies :restart, "service[httpd]", :immediately
  variables({
    :wordpress => wordpress,
  })
end
