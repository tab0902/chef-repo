#
# Cookbook:: mod_wsgi
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

wsgi_conf         = node['mod_wsgi']['wsgi_conf']
vhost_conf        = node['mod_wsgi']['vhost_conf']
user_name         = node['user']['name']
projects          = node['repository']['repositories']
domains           = node['certbot']['domains']
miniconda_version = node['miniconda']['version']
python_version    = node['miniconda']['python']['version']

certbot  = "/home/#{user_name}/certbot"
pip      = "/home/#{user_name}/.pyenv/versions/miniconda#{python_version.to_i}-#{miniconda_version}/bin/pip"
mod_wsgi = "/home/#{user_name}/.pyenv/versions/miniconda#{python_version.to_i}-#{miniconda_version}/lib/python#{python_version}/site-packages/mod_wsgi"

project_names = []
projects.each do |project|
  project_names.push(project['name'])
end

template "#{wsgi_conf}" do
  owner "root"
  group "root"
  mode 0644
  source "wsgi.conf.erb"
  not_if "find #{certbot}"
  variables({
    :user_name => user_name,
    :miniconda_version => miniconda_version,
    :python_version => python_version,
    :project_name => project_names[0]
  })
end

template "#{vhost_conf}" do
  owner "root"
  group "root"
  mode 0644
  source "vhost.conf.erb"
  only_if "find #{certbot}"
  variables({
    :user_name => user_name,
    :miniconda_version => miniconda_version,
    :python_version => python_version,
    :project_names => project_names,
    :domains => domains
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
