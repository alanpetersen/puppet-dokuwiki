#
class dokuwiki::params {

  $download_url   = 'http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz'
  $version        = undef
  $autolink       = true
  $install_dir    = '/opt/www/dokuwiki'
  $license        = 'cc-by-sa'
  $wiki_title     = undef
  $language       = 'en'
  $useacl         = '1'
  $superuser      = 'admin'
  $superpassword  = 'password'
  $superemail     = 'admin@host.com'
  $disableactions = ['register']
  $htaccess       = 'puppet:///modules/dokuwiki/htaccess'
  $authad         = 0
  $authldap       = 0
  $authmysql      = 0
  $authpgsql      = 0

  case $::osfamily {
    'debian': {
      $www_owner = 'www-data'
      $www_group = 'www-data'
    }
    'redhat': {
      $www_owner = 'apache'
      $www_group = 'apache'
    }
    default: {
      $www_owner = 'root'
      $www_group = 'root'
    }
  }

}
