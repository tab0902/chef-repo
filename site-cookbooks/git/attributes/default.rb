default['git']['source_uri'] = "https://www.kernel.org/pub/software/scm/git/git-#{node['git']['version']}.tar.gz"
default['git']['install_dir'] = "/usr/local"
default['git']['packages']['pre'] = %w{ libcurl-devel expat-devel gettext openssl-devel perl-devel zlib-devel gcc perl-ExtUtils-MakeMaker }
default['git']['packages']['post'] = %w{ gettext-devel }
