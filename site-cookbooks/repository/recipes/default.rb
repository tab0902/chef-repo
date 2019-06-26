#
# Cookbook:: repository
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'cgi'

user_name    = node['user']['name']
repositories = node['repository']['repositories']
install_dir  = node['git']['install_dir']

git = "#{install_dir}/bin/git"

data_bag = Chef::EncryptedDataBagItem.load('passwords','github')

repositories.each do |repository|
  repo_owner = repository['owner']
  repo_name  = repository['name']
  repo_url   = "https://github.com/#{repo_owner}/#{repo_name}.git"

  if data_bag.to_hash.has_key?("#{repo_owner}") then
    password = CGI.escape(data_bag["#{repo_owner}"])
    repo_url = "https://#{repo_owner}:#{password}@github.com/#{repo_owner}/#{repo_name}.git"
  end

  git "/home/#{user_name}/#{repo_name}" do
    repository "#{repo_url}"
    revision "master"
    user "#{user_name}"
    group "#{user_name}"
    action :checkout
    not_if "find /home/#{user_name}/#{repo_name}"
    notifies :run, "execute[remote_set_url_for_#{repo_name}]", :immediately
  end

  execute "remote_set_url_for_#{repo_name}" do
    action :nothing
    user "#{user_name}"
    group "#{user_name}"
    cwd "/home/#{user_name}/#{repo_name}"
    command <<-EOS
      #{git} remote set-url origin git@github.com:#{repo_owner}/#{repo_name}
    EOS
  end
end
