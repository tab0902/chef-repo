#
# Cookbook:: certbot
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

user_name  = node['user']['name']
repository = node['certbot']['repository']
ssl_conf   = node['certbot']['ssl_conf']
webroot    = node['certbot']['webroot']
domaim     = node['certbot']['domain']
email      = node['certbot']['email']

cert_file  = "/etc/letsencrypt/live/#{domaim}/cert.pem"
key_file   = "/etc/letsencrypt/live/#{domaim}/privkey.pem"
chain_file = "/etc/letsencrypt/live/#{domaim}/chain.pem"

git "/home/#{user_name}/certbot" do
  repository "#{repository}"
  revision "master"
  user "#{user_name}"
  group "#{user_name}"
  action :checkout
  notifies :run, "execute[set_env_for_certbot]", :immediately
end

execute "set_env_for_certbot" do
  action :nothing
  user "#{user_name}"
  group "#{user_name}"
  environment "HOME" => "/home/#{user_name}"
  notifies :run, "execute[create_cert]", :immediately
  command <<-EOS
    echo 'export PATH="$HOME/certbot:$PATH"' >> ~/.bashrc
    source ~/.bashrc
  EOS
end

execute "create_cert" do
  action :nothing
  user "root"
  group "root"
  cwd "/home/#{user_name}/certbot"
  command <<-EOS
    ./certbot-auto certonly --agree-tos --webroot -w #{webroot} -d #{domaim} -m #{email} -n --keep
  EOS
end

template "#{ssl_conf}" do
  owner "root"
  group "root"
  mode 0644
  source "ssl.conf.erb"
  variables({
    :cert_file => cert_file,
    :key_file => key_file,
    :chain_file => chain_file,
  })
end
