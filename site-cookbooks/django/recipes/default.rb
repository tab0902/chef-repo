#
# Cookbook:: django
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name         = node['user']['name']
miniconda_version = node['miniconda']['version']
python_version    = node['miniconda']['python']['version']
packages          = node['django']['packages']

miniconda = "/home/#{user_name}/.pyenv/versions/miniconda3-#{miniconda_version}"
pip      = "#{miniconda}/bin/pip"
google   = "#{miniconda}/lib/python#{python_version}/site-packages/google"
line_py  = "#{miniconda}/lib/python#{python_version}/site-packages/social_core/backends/line.py"

execute "install_django_and_other_packages" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  not_if "find #{google}"
  command <<-EOS
    #{pip} install --upgrade pip
    #{pip} install #{packages.join("\s")}
    #{pip} uninstall -y PyOpenSSL
  EOS
end

template "#{line_py}" do
  owner "#{user_name}"
  group "#{user_name}"
  mode 0644
  source "line.py.erb"
end
