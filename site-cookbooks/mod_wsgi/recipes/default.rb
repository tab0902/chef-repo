#
# Cookbook:: mod_wsgi
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

wsgi_conf         = node['mod_wsgi']['wsgi_conf']
python_conf       = node['mod_wsgi']['python_conf']
user_name         = node['user']['name']
project_name      = node['repository']['name']
miniconda_version = node['miniconda']['version']
python_version    = node['miniconda']['python']['version']

pip      = "/home/#{user_name}/.pyenv/versions/miniconda3-#{miniconda_version}/bin/pip"
mod_wsgi = "/home/#{user_name}/.pyenv/versions/miniconda3-#{miniconda_version}/lib/python#{python_version}/site-packages/mod_wsgi"

template "#{wsgi_conf}" do
  owner "root"
  group "root"
  mode 0644
  source "wsgi.conf.erb"
  variables({
    :user_name => user_name,
    :python_version => python_version,
    :miniconda_version => miniconda_version
  })
end

template "#{python_conf}" do
  owner "root"
  group "root"
  mode 0644
  source "python.conf.erb"
  variables({
    :user_name => user_name,
    :miniconda_version => miniconda_version,
    :project_name => project_name
  })
end

execute "install_mod_wsgi" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  not_if "find #{mod_wsgi}"
  notifies :restart, "service[httpd]", :immediately
  command <<-EOS
    #{pip} install mod_wsgi
  EOS
end
