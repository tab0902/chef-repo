#
# Cookbook:: mod_wsgi
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

wsgi_conf         = node['mod_wsgi']['wsgi_conf']
projects          = node['mod_wsgi']['projects']
user_name         = node['user']['name']
miniconda_version = node['miniconda']['version']
python_version    = node['miniconda']['python']['version']

certbot   = "/home/#{user_name}/certbot"
miniconda = "/home/#{user_name}/.pyenv/versions/miniconda#{python_version.to_i}-#{miniconda_version}"
mod_wsgi  = "#{miniconda}/lib/python#{python_version}/site-packages/mod_wsgi"

template "#{wsgi_conf}" do
  owner "root"
  group "root"
  mode 0644
  source "wsgi.conf.erb"
  notifies :reload, "service[httpd]", :delayed
  variables({
    :user_name => user_name,
    :miniconda_version => miniconda_version,
    :python_version => python_version,
    :projects => projects
  })
end

execute "install_mod_wsgi" do
  user "#{user_name}"
  group "#{user_name}"
  environment ({
    "HOME" => "/home/#{user_name}",
    "PATH" => "#{miniconda}/bin:#{ENV['PATH']}"
  })
  not_if "find #{mod_wsgi}"
  command <<-EOS
    pip install mod_wsgi
  EOS
end
