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
projects   = node["wordpress"]["projects"]
environment = node.chef_environment


projects.each do |key, project|

  source      = "/home/#{user_name}/#{repository}"
  destination = "/home/#{user_name}#{project['destination']}"
  directory   = "#{project['directory']}"
  db_name     = "#{project['db_name']}"

  remote_file "#{source}" do
    owner "#{user_name}"
    group "#{user_name}"
    mode 0644
    source "http://ja.wordpress.org/#{repository}"
    not_if "find #{destination}/#{directory}"
  end

  execute "unzip_wordpress" do
    user "#{user_name}"
    group "#{user_name}"
    cwd "/home/#{user_name}"
    not_if "find #{destination}/#{directory}"
    command <<-EOS
      tar xfz #{source}
    EOS
  end

  file "#{source}" do
    action :delete
  end

  execute "rename_directory" do
    user "#{user_name}"
    group "#{user_name}"
    not_if "find #{destination}/#{directory}"
    command <<-EOS
      mv #{destination}/wordpress #{destination}/#{directory}
    EOS
  end

  execute "chmod_wp-content" do
    user "#{user_name}"
    group "#{user_name}"
    not_if "test `stat -c '%a' #{destination}/#{directory}/wp-content` -eq '777'"
    command <<-EOS
      chmod -R 777 #{destination}/#{directory}/wp-content
    EOS
  end

  data_bag = Chef::EncryptedDataBagItem.load('passwords','mysql')
  password = data_bag["#{environment}"]

  template "#{destination}/#{directory}/wp-config.php" do
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
end
