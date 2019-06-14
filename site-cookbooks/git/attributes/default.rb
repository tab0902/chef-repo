default['git']['source_uri'] = "https://www.kernel.org/pub/software/scm/git/git-#{node['git']['version']}.tar.gz"
default['git']['install_dir'] = "/usr/local"
default['git']['packages'] = %w{ libcurl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel gcc autoconf perl-ExtUtils-MakeMaker }
