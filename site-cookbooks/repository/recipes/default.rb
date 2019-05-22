#
# Cookbook:: repository
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name    = node['user']['name']
repositories = node['repository']['repositories']

repositories.each do |repository|
  repo_owner = repository['owner']
  repo_name  = repository['name']

  git "/home/#{user_name}/#{repo_name}" do
    repository "https://github.com/#{repo_owner}/#{repo_name}.git"
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
      git remote set-url origin git@github.com:#{repo_owner}/#{repo_name}
    EOS
  end
end
