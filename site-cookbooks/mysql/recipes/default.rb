#
# Cookbook:: mysql
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

repository  = node['mysql']['repository']
db_names    = node["mysql"]["db_names"]
db_host     = node['mysql']['db_host']
my_cnf      = node['mysql']['my_cnf']
config      = node['mysql']['config']
charset     = node['mysql']['config']['charset']
collate     = node['mysql']['config']['collate']
user_name   = node["user"]["name"]
hostname    = node['hostname']
environment = node.chef_environment

remote_file "#{Chef::Config[:file_cache_path]}/#{repository}" do
  source "http://repo.mysql.com/#{repository}"
end

rpm_package "mysql-community-release" do
  source "#{Chef::Config[:file_cache_path]}/#{repository}"
  action :install
end

%W{ mysql-community-server mysql-community-devel.x86_64 }.each do |item|
  package "#{item}" do
    action [ :install, :upgrade ]
    options "--disablerepo=mysql57-community --enablerepo=mysql56-community"
  end
end

service 'mysqld' do
  action [ :enable, :start ]
end

data_bag = Chef::EncryptedDataBagItem.load('passwords','mysql')
password = data_bag["#{environment}"]

template "#{Chef::Config[:file_cache_path]}/secure_install.sql" do
  owner "root"
  group "root"
  mode 0644
  source "secure_install.sql.erb"
  not_if "mysql -u root -p#{password} -D #{db_names[0]}"
  notifies :run, "execute[secure_install]", :immediately
  variables({
    :password => password,
  })
end

execute "secure_install" do
  action :nothing
  user "root"
  group "root"
  only_if "mysql -u root -e 'show databases;'"
  command "mysql -u root < #{Chef::Config[:file_cache_path]}/secure_install.sql"
end

file "#{Chef::Config[:file_cache_path]}/secure_install.sql" do
  action :delete
end

template "#{my_cnf}" do
  owner "root"
  group "root"
  mode 0644
  source 'my.cnf.erb'
  notifies :restart, 'service[mysqld]', :immediately
  variables({
    :hostname => hostname,
    :user_name => user_name,
    :password => password,
    :config => config
  })
end

template "#{Chef::Config[:file_cache_path]}/create_db.sql" do
  owner "root"
  group "root"
  mode 0644
  source "create_db.sql.erb"
  not_if "mysql -u root -p#{password} -D #{db_names[0]}"
  notifies :run, "execute[create_db]", :immediately
  variables({
    :db_names => db_names,
    :db_host => db_host,
    :user_name => user_name,
    :password => password,
    :charset => charset,
    :collate => collate
  })
end

execute "create_db" do
  action :nothing
  user "root"
  group "root"
  command "mysql -u root -p#{password} < #{Chef::Config[:file_cache_path]}/create_db.sql"
end

file "#{Chef::Config[:file_cache_path]}/create_db.sql" do
  action :delete
end
