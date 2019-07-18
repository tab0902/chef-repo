#
# Cookbook:: cakephp
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

version       = node['php']['version']
user_name     = node['user']['name']
projects      = node['cakephp']['projects']
composer_dir  = node['composer']['install_dir']
composer_file = node['composer']['file_name']

composer = "#{composer_dir}/#{composer_file}"

package "php-intl" do
  action [ :install, :upgrade ]
  options "--enablerepo=remi,remi-php#{version}"
end

projects.each do |project|

  execute "install_cakephp_files_to_#{project}" do
    user "#{user_name}"
    group "#{user_name}"
    cwd "/home/#{user_name}/#{project}"
    not_if "find /home/#{user_name}/#{project}/vendor"
    command <<-EOS
      #{composer} install -n
    EOS
  end
end
