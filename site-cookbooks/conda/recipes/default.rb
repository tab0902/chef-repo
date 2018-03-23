#
# Cookbook:: conda
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name         = node['user']['name']
miniconda_version = node['miniconda']['version']
python_version    = node['miniconda']['python']['version']
packages          = node['conda']['packages']

miniconda     = "/home/#{user_name}/.pyenv/versions/miniconda3-#{miniconda_version}"
conda         = "#{miniconda}/bin/conda"
site_packages = "#{miniconda}/lib/python#{python_version}/site-packages"

packages.each do |key, value|
  execute "install_#{key}" do
    user "#{user_name}"
    group "#{user_name}"
    environment "HOME" => "/home/#{user_name}"
    not_if "find #{site_packages}/#{value[:dir]}"
    command <<-EOS
      #{conda} install -y #{value[:pkg]}
    EOS
  end
end

execute "mkdir_ml" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  not_if "find /home/#{user_name}/ml"
  command <<-EOS
    mkdir ~/ml
  EOS
end
