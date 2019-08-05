#
# Cookbook:: miniconda
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name         = node['user']['name']
miniconda_version = node['miniconda']['version']
python_version    = node['miniconda']['python']['version']

miniconda = "/home/#{user_name}/.pyenv/versions/miniconda#{python_version.to_i}-#{miniconda_version}"

execute "install_miniconda" do
  user "#{user_name}"
  group "#{user_name}"
  environment ({
    "HOME" => "/home/#{user_name}",
    "PATH" => "/home/#{user_name}/.pyenv/bin:#{ENV['PATH']}"
  })
  not_if "find #{miniconda}"
  command <<-EOS
    pyenv install miniconda#{python_version.to_i}-#{miniconda_version}
    pyenv rehash
    pyenv global miniconda#{python_version.to_i}-#{miniconda_version}
    echo 'export PATH="$PYENV_ROOT/versions/miniconda#{python_version.to_i}-#{miniconda_version}/bin/:$PATH"' >> ~/.bashrc
    source ~/.bashrc
  EOS
end
