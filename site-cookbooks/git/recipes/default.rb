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
    action [ :install, :upgrade ]
  end
end

remote_file "#{Chef::Config[:file_cache_path]}/git-#{version}.tar.gz" do
  source "#{source_uri}"
end

execute "install_git" do
  user "root"
  group "root"
  not_if "find #{install_dir}/bin/git"
  command <<-EOS
    cd #{install_dir}/src
    tar xfz #{Chef::Config[:file_cache_path]}/git-#{version}.tar.gz -C #{install_dir}/src
    cd #{install_dir}/src/git-#{version}
    make configure
    ./configure --prefix=#{install_dir}
    make all
    make install
  EOS
  notifies :run, "execute[rehash]", :immediately
end

execute "rehash" do
  action :nothing
  user "#{user_name}"
  group "#{user_name}"
  command <<-EOS
    hash -r
  EOS
end

execute "git_settings" do
  user "#{user_name}"
  group "#{user_name}"
  environment ({
    "HOME" => "/home/#{user_name}",
    "PATH" => "#{install_dir}/bin:#{ENV['PATH']}"
  })
  not_if "find /home/#{user_name}/.ssh/id_rsa"
  command <<-EOS
    git config --global merge.ff false
    git config --global pull.ff only
    git config --global push.default current
    git config --global core.whitespace cr-at-eol
    ssh-keygen -f /home/#{user_name}/.ssh/id_rsa -t rsa -N ""
  EOS
end
