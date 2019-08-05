#
# Cookbook:: node
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

user_name = node['user']['name']
version   = node['node']['version']
projects  = node['node']['projects']

%W{ nodejs npm }.each do |item|
  package "#{item}" do
    action [ :install, :upgrade ]
    not_if "find /usr/bin/n"
  end
end

execute "install_n" do
  user "root"
  group "root"
  not_if "find /usr/bin/n"
  command <<-EOS
    npm config set strict-ssl false
    npm i -g n
    npm config set strict-ssl true
  EOS
  notifies :run, "execute[update_node]", :immediately
end

execute "update_node" do
  action :nothing
  user "root"
  group "root"
  command <<-EOS
    n #{version}
  EOS
  notifies :run, "execute[rehash]", :immediately
end

execute "rehash" do
  action :nothing
  user "#{user_name}"
  group "#{user_name}"
  command <<-EOS
    hash -r
  EOS
end

%W{ nodejs npm }.each do |item|
  package "#{item}" do
    action :remove
  end
end

execute "update_npm" do
  user "root"
  group "root"
  environment ({
    "PATH" => "/usr/local/bin:#{ENV['PATH']}"
  })
  command <<-EOS
    npm up -g npm
  EOS
end


projects.each do |project, value|

  packages = value['packages']

  execute "npm_init" do
    user "#{user_name}"
    group "#{user_name}"
    cwd "/home/#{user_name}/#{project}"
    environment ({
      "HOME" => "/home/#{user_name}",
      "PATH" => "/usr/local/bin:#{ENV['PATH']}"
    })
    not_if "find /home/#{user_name}/#{project}/package.json"
    command <<-EOS
      npm init -y
    EOS
    packages['save'].each do |package|
      notifies :run, "execute[npm_install__save_#{package}]", :immediately
    end
    packages['save_dev'].each do |package|
      notifies :run, "execute[npm_install__save_dev_#{package}]", :immediately
    end
  end

  execute "npm_install" do
    user "#{user_name}"
    group "#{user_name}"
    cwd "/home/#{user_name}/#{project}"
    environment ({
      "HOME" => "/home/#{user_name}",
      "PATH" => "/usr/local/bin:#{ENV['PATH']}"
    })
    only_if "find /home/#{user_name}/#{project}/package.json"
    command <<-EOS
      npm i
    EOS
  end

  packages['save'].each do |package|
    execute "npm_install__save_#{package}" do
      action :nothing
      user "#{user_name}"
      group "#{user_name}"
      cwd "/home/#{user_name}/#{project}"
      environment ({
        "HOME" => "/home/#{user_name}",
        "PATH" => "/usr/local/bin:#{ENV['PATH']}"
      })
      command <<-EOS
        npm i -S #{package}
      EOS
    end
  end

  packages['save_dev'].each do |package|
    execute "npm_install__save_dev_#{package}" do
      action :nothing
      user "#{user_name}"
      group "#{user_name}"
      cwd "/home/#{user_name}/#{project}"
      environment ({
        "HOME" => "/home/#{user_name}",
        "PATH" => "/usr/local/bin:#{ENV['PATH']}"
      })
      command <<-EOS
        npm i -D #{package}
      EOS
    end
  end

  packages['global'].each do |package|
    execute "npm_install__global_#{package}" do
      user "root"
      group "root"
      environment ({
        "PATH" => "/usr/local/bin:#{ENV['PATH']}"
      })
      not_if "find /usr/local/lib/node_modules/#{package}"
      command <<-EOS
        npm i -g #{package}
      EOS
    end
  end
end
