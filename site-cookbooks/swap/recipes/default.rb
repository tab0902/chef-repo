#
# Cookbook:: swap
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

path = node['swap']['path']
size = node['swap']['size']

swap_file "#{path}" do
  persist true
  size size
end
