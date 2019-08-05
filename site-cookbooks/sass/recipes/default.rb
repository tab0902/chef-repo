#
# Cookbook:: sass
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

user_name = node['user']['name']
projects  = node['sass']['projects']

# package "libffi-devel" do
#   action [ :install, :upgrade ]
# end

%W{ sass ffi }.each do |item|
  gem_package "#{item}" do
    action [ :install, :upgrade ]
  end
end


projects.each do |project, value|

  extension = value['extension']
  dirs      = value['dirs']
  extension = value['extension']
  cascade   = value['cascade']
  minify    = value['minify']

  template "/home/#{user_name}/#{project}/gulpfile.js" do
    owner "#{user_name}"
    group "#{user_name}"
    mode 0644
    source "gulpfile.js.erb"
    action :create_if_missing
    variables({
      :dirs => dirs,
      :extension => extension,
      :cascade => cascade,
      :minify => minify,
    })
  end

  execute "gulp css" do
    user "#{user_name}"
    group "#{user_name}"
    cwd "/home/#{user_name}/#{project}"
    environment ({
      "HOME" => "/home/#{user_name}",
      "PATH" => "/usr/local/bin:#{ENV['PATH']}"
    })
    command <<-EOS
      gulp css
    EOS
  end
end
