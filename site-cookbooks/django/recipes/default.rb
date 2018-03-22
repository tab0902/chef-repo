#
# Cookbook:: django
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name         = node['user']['name']
miniconda_version = node['miniconda']['version']
python_version    = node['miniconda']['python']['version']
packages          = node['django']['packages']

miniconda     = "/home/#{user_name}/.pyenv/versions/miniconda3-#{miniconda_version}"
pip           = "#{miniconda}/bin/pip"
site_packages = "#{miniconda}/lib/python#{python_version}/site-packages"
line_py       = "#{site_packages}/social_core/backends/line.py"

execute "upgrade_pip" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  command <<-EOS
    #{pip} install --upgrade pip
  EOS
end

packages.each_value do |item|
  execute "install_#{item[:pkg]}" do
    user "#{user_name}"
    group "#{user_name}"
    environment "HOME" => "/home/#{user_name}"
    not_if "find #{site_packages}/#{item[:dir]}"
    command <<-EOS
      #{pip} install #{item[:pkg]}
    EOS
  end
end

execute "uninstall_pyopenssl" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  only_if "find #{site_packages}/OpenSSL"
  command <<-EOS
    #{pip} uninstall -y PyOpenSSL
  EOS
end

template "#{line_py}" do
  owner "#{user_name}"
  group "#{user_name}"
  mode 0644
  source "line.py.erb"
end
