default['git']['version']    = "2.21.0"
default['git']['source_uri'] = "https://www.kernel.org/pub/software/scm/git/git-#{default['git']['version']}.tar.gz"
default['git']['install_dir'] = "/usr/local"
default['git']['packages']   = %w{ libcurl-devel expat-devel gettext gettext-devel openssl-devel perl-devel zlib-devel gcc perl-ExtUtils-MakeMaker }
