#
# Cookbook:: selinux
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

execute 'disable_selinux' do
  user 'root'
  group 'root'
  not_if "grep -q 'SELINUX=disabled' /etc/sysconfig/selinux"
  command <<-EOS
    setenforce 0
    cp -p /etc/sysconfig/selinux /etc/sysconfig/selinux.old
    cat /etc/sysconfig/selinux.old | sed 's/^SELINUX=.*$/SELINUX=disabled/' > /etc/sysconfig/selinux
  EOS
end
