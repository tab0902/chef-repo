#
# Cookbook:: cakephp
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

version       = node['php']['version']
user_name     = node['user']['name']
repositories  = node['repository']['repositories']
composer_dir  = node['composer']['install_dir']
composer_file = node['composer']['file_name']

composer = "#{composer_dir}/#{composer_file}"

package "php-intl" do
  action [ :install, :upgrade ]
  options "--enablerepo=remi,remi-php#{version}"
end

repositories.each do |repository|
  repo_name = repository['name']

  execute "install_cakephp_files_to_#{repo_name}" do
    user "#{user_name}"
    group "#{user_name}"
    cwd "/home/#{user_name}/#{repo_name}"
    not_if "find /home/#{user_name}/#{repo_name}/vendor"
    command <<-EOS
      #{composer} install -n
    EOS
  end
end
