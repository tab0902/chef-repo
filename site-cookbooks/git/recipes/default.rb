#
# Cookbook:: git
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

version     = node['git']['version']
source_uri  = node['git']['source_uri']
install_dir = node['git']['install_dir']
user_name   = node['user']['name']

node['git']['packages'].each do |item|
  package "#{item}" do
    [ :install, :upgrade ]
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/git-#{version}.tar.gz" do
  source "#{source_uri}"
end

execute "install_git" do
  user "root"
  group "root"
  not_if "find #{install_dir}/git-#{version}"
  command <<-EOS
    cd #{install_dir}
    tar xfz #{Chef::Config[:file_cache_path]}/git-#{version}.tar.gz -C #{install_dir}
    cd #{install_dir}/git-#{version}
    make configure
    ./configure --prefix=/usr
    make all
    make install
  EOS
end

execute "git_settings" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  not_if "find /home/#{user_name}/.ssh/id_rsa"
  command <<-EOS
    git config --global merge.ff false
    git config --global pull.ff only
    git config --global push.default current
    git config --global core.whitespace cr-at-eol
    ssh-keygen -f /home/#{user_name}/.ssh/id_rsa -t rsa -N ""
  EOS
end
