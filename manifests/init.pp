# Class: dokuwiki
# ===========================
#
# Full description of class dokuwiki here.
#
# Examples
# --------
#
# @example
#    class { 'dokuwiki':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Alan Petersen <alan@alanpetersen.net>
#
# Copyright
# ---------
#
# Copyright 2016 Alan Petersen, unless otherwise noted.
#
class dokuwiki(
  $install_dir    = $dokuwiki::params::install_dir,
  $download_url   = $dokuwiki::params::download_url,
  $version        = $dokuwiki::params::version,
  $autolink       = $dokuwiki::params::autolink,
  $www_owner      = $dokuwiki::params::www_owner,
  $www_group      = $dokuwiki::params::www_group,
  $htaccess       = $dokuwiki::params::htaccess,
  $wiki_title     = $dokuwiki::params::wiki_title,
  $license        = $dokuwiki::params::license,
  $language       = $dokuwiki::params::language,
  $useacl         = $dokuwiki::params::useacl,
  $superuser      = $dokuwiki::params::superuser,
  $superpassword  = $dokuwiki::params::superpassword,
  $superemail     = $dokuwiki::params::superemail,
  $disableactions = $dokuwiki::params::disableactions,
  $authad         = $dokuwiki::params::authad,
  $authldap       = $dokuwiki::params::authldap,
  $authmysql      = $dokuwiki::params::authmysql,
  $authpgsql      = $dokuwiki::params::authpgsql,
) inherits dokuwiki::params {

  dokuwiki::app { $install_dir:
    download_url   => $download_url,
    version        => $version,
    autolink       => $autolink,
    www_owner      => $www_owner,
    www_group      => $www_group,
    htaccess       => $htaccess,
    wiki_title     => $wiki_title,
    license        => $license,
    language       => $language,
    useacl         => $useacl,
    superuser      => $superuser,
    superpassword  => $superpassword,
    superemail     => $superemail,
    disableactions => $disableactions,
    authad         => $authad,
    authldap       => $authldap,
    authmysql      => $authmysql,
    authpgsql      => $authpgsql,
  }


}
