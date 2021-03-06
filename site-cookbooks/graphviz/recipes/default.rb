#
# Cookbook:: graphviz
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name         = node['user']['name']
miniconda_version = node['miniconda']['version']
python_version    = node['miniconda']['python']['version']

miniconda     = "/home/#{user_name}/.pyenv/versions/miniconda#{python_version.to_i}-#{miniconda_version}"
site_packages = "#{miniconda}/lib/python#{python_version}/site-packages"

package "graphviz" do
  action [ :install, :upgrade ]
end

execute "install_graphviz" do
  user "#{user_name}"
  group "#{user_name}"
  environment ({
    "HOME" => "/home/#{user_name}",
    "PATH" => "#{miniconda}/bin:#{ENV['PATH']}"
  })
  not_if "find #{site_packages}/graphviz"
  command <<-EOS
    pip install graphviz
  EOS
end
