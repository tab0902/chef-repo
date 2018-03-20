#
# Cookbook:: miniconda
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name         = node['user']['name']
miniconda_version = node['miniconda']['version']

pyenv     = "/home/#{user_name}/.pyenv/bin/pyenv"
miniconda = "/home/#{user_name}/.pyenv/versions/miniconda3-#{miniconda_version}"

execute "install_miniconda" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  not_if "find #{miniconda}"
  command <<-EOS
    #{pyenv} install miniconda3-#{miniconda_version}
    #{pyenv} rehash
    #{pyenv} global miniconda3-#{miniconda_version}
    echo 'export PATH="$PYENV_ROOT/versions/miniconda3-#{miniconda_version}/bin/:$PATH"' >> ~/.bashrc
    source ~/.bashrc
  EOS
end
