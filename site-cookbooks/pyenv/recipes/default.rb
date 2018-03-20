#
# Cookbook:: pyenv
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name         = node['user']['name']
pyenv_repository  = node['pyenv']['repository']

git "/home/#{user_name}/.pyenv" do
  repository "#{pyenv_repository}"
  revision "master"
  user "#{user_name}"
  group "#{user_name}"
  action :checkout
  notifies :run, "execute[set_env_for_pyenv]", :immediately
end

execute "set_env_for_pyenv" do
  action :nothing
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  command <<-EOS
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    source ~/.bashrc
  EOS
end
