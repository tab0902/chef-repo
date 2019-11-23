default['wkhtmltopdf']['source_uri'] = "https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/#{node['wkhtmltopdf']['version']}/wkhtmltox-#{node['wkhtmltopdf']['version']}_linux-generic-amd64.tar.xz"
default['wkhtmltopdf']['install_dir'] = "/usr/local"
default['wkhtmltopdf']['packages'] = %w{ libXrender libXext ipa-gothic-fonts ipa-mincho-fonts ipa-pgothic-fonts ipa-pmincho-fonts }
