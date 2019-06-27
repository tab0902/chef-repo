#
# Cookbook:: certbot
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

if node['certbot'].has_key?("domains") then

  user_name  = node['user']['name']
  repository = node['certbot']['repository']
  ssl_conf   = node['certbot']['ssl_conf']
  webroot    = node['certbot']['webroot']
  domains    = node['certbot']['domains']
  email      = node['certbot']['email']

  git "/home/#{user_name}/certbot" do
    repository "#{repository}"
    revision "master"
    user "#{user_name}"
    group "#{user_name}"
    action :sync
  end

  execute "set_env_for_certbot" do
    user "#{user_name}"
    group "#{user_name}"
    environment "HOME" => "/home/#{user_name}"
    not_if "grep -q '$HOME/certbot:$PATH' /home/#{user_name}/.bashrc"
    command <<-EOS
      echo 'export PATH="$HOME/certbot:$PATH"' >> ~/.bashrc
      source ~/.bashrc
    EOS
  end

  domains.each do |project_name, domain|
    execute "create_cert_for_#{project_name}" do
      user "root"
      group "root"
      cwd "/home/#{user_name}/certbot"
      not_if "find /etc/letsencrypt/live/#{domain}"
      command <<-EOS
        ./certbot-auto certonly --agree-tos --webroot -w #{webroot} -d #{domain} -m #{email} -n --keep
      EOS
    end
  end

end
