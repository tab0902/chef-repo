#
# Cookbook:: ruby
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

user_name              = node['user']['name']
version                = node['ruby']['version']
rbenv_repository       = node['ruby']['repository']['rbenv']
ruby_build_repository  = node['ruby']['repository']['ruby_build']

rbenv = "/home/#{user_name}/.rbenv/bin/rbenv"
gem   = "/home/#{user_name}/.rbenv/shims/gem"

git "/home/#{user_name}/.rbenv" do
  repository "#{rbenv_repository}"
  revision "master"
  user "#{user_name}"
  group "#{user_name}"
  action :sync
end

directory "/home/#{user_name}/.rbenv/plugins" do
  owner "#{user_name}"
  group "#{user_name}"
  mode 0755
end

git "/home/#{user_name}/.rbenv/plugins/ruby-build" do
  repository "#{ruby_build_repository}"
  revision "master"
  user "#{user_name}"
  group "#{user_name}"
  action :sync
end

execute "set_env_for_rbenv" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  not_if "grep -q '$RBENV_ROOT/bin:$PATH' /home/#{user_name}/.bashrc"
  command <<-EOS
    echo 'export RBENV_ROOT="$HOME/.rbenv"' >> ~/.bashrc
    echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    source ~/.bashrc
  EOS
end

execute "install_ruby" do
  user "#{user_name}"
  group "#{user_name}"
  not_if "find /home/#{user_name}/.rbenv/versions/#{version}"
  environment "HOME" => "/home/#{user_name}"
  command <<-EOS
    #{rbenv} install #{version}
    #{rbenv} rehash
    #{rbenv} global #{version}
  EOS
end

execute "update_gem" do
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  command <<-EOS
    #{gem} update --system
  EOS
end
