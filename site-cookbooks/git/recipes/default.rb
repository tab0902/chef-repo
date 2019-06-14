#
# Cookbook:: git
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

version     = node['git']['version']
source_uri  = node['git']['source_uri']
install_dir = node['git']['install_dir']
user_name   = node['user']['name']

download_dir = "#{install_dir}/src"
git          = "#{install_dir}/bin/git"

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
  not_if "find #{download_dir}/git-#{version}"
  command <<-EOS
    cd #{download_dir}
    tar xfz #{Chef::Config[:file_cache_path]}/git-#{version}.tar.gz -C #{download_dir}
    cd #{download_dir}/git-#{version}
    make configure
    ./configure --prefix=#{install_dir}
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
