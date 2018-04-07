#
# Cookbook:: jupyter
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

node_name = node.name
user_name = node['user']['name']
port      = node['jupyter']['port']

jupyter = "/home/#{user_name}/.jupyter"

directory "#{jupyter}" do
  owner "#{user_name}"
  group "#{user_name}"
  mode 0755
end

data_bag = Chef::EncryptedDataBagItem.load('tokens','jupyter')
token = data_bag["token"]

template "#{jupyter}/jupyter_notebook_config.py" do
  owner "#{user_name}"
  group "#{user_name}"
  mode 0644
  source "jupyter_notebook_config.py.erb"
  variables({
    :port => port,
    :token => token
  })
end
