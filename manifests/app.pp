#
define dokuwiki::app (
  $download_url,
  $version,
  $autolink,
  $www_owner,
  $www_group,
  $htaccess,
  $wiki_title,
  $license,
  $language,
  $useacl,
  $superuser,
  $superpassword,
  $superemail,
  $disableactions,
  $authad,
  $authldap,
  $authmysql,
  $authpgsql,
  $install_dir = $title,
) {

  # manage the staging class
  class { 'staging':
    path  => '/var/staging',
  }

  # get the parent directory... the dokuwiki distribution
  # gets extracted to a release subdirectory
  $install_parent = getparent($install_dir)
  # ensure that the parent directory exists and is owned appropriately
  if !defined(File[$install_parent]) {
    file { $install_parent:
      ensure => directory,
      owner  => $www_owner,
      group  => $www_group,
      mode   => '0755',
    }
  }

  # download the staged file
  staging::file { 'dokuwiki.tgz':
    source => $download_url,
  }

  staging::extract { 'dokuwiki.tgz':
    target  => $install_parent,
    user    => $www_owner,
    group   => $www_group,
    creates => "${install_dir}/doku.php",
    require => Staging::File['dokuwiki.tgz'],
  }

  # autolink will run a script to examine the distro for the
  # version number and then create a symlink on the system
  #
  if $autolink {
    $gen_symlink_cmd = '/tmp/gen_symlink.sh'

    file {$gen_symlink_cmd:
      ensure  => file,
      content => template('dokuwiki/gen_symlink.erb'),
      mode    => '0700',
      owner   => $www_owner,
      group   => $www_group,
    }

    exec { 'create_symlink':
      command   => $gen_symlink_cmd,
      user      => $www_owner,
      group     => $www_group,
      logoutput => true,
      path      => '/bin:/usr/bin:/usr/local/bin',
      creates   => $install_dir,
      require   => Staging::Extract['dokuwiki.tgz'],
    }

    file { $install_dir:
      ensure  => present,
      owner   => $www_owner,
      group   => $www_group,
      require => Exec['create_symlink'],
    }

    file { "${install_dir}/install.php":
      ensure  => absent,
      require => Exec['create_symlink'],
    }
  } else {
    if $version == undef {
      fail('version parameter is required if autolink is disabled')
    }
    # ensure that the directory exists and is owned appropriately
    if !defined(File["${install_parent}/dokuwiki-${version}"]) {
      file { "${install_parent}/dokuwiki-${version}":
        ensure  => directory,
        owner   => $www_owner,
        group   => $www_group,
        recurse => true,
        mode    => '0755',
      }
    }
    file { $install_dir:
      ensure => link,
      target => "${install_parent}/dokuwiki-${version}",
      owner  => $www_owner,
      group  => $www_group,
    }

    file { "${install_dir}/install.php":
      ensure  => absent,
      require => File[$install_dir],
    }
  }

  file { 'htaccess':
    ensure  => file,
    path    => "${install_dir}/.htaccess",
    owner   => $www_owner,
    group   => $www_group,
    mode    => '0600',
    source  => $htaccess,
    require => File[$install_dir],
  }

  file { 'local.php':
    ensure  => file,
    path    => "${install_dir}/conf/local.php",
    owner   => $www_owner,
    group   => $www_group,
    mode    => '0644',
    content => template('dokuwiki/local.php.erb'),
    require => File[$install_dir],
  }

  file { 'plugins.local.php':
    ensure  => file,
    path    => "${install_dir}/conf/plugins.local.php",
    owner   => $www_owner,
    group   => $www_group,
    mode    => '0644',
    content => template('dokuwiki/plugins.local.php.erb'),
    require => File[$install_dir],
  }

  # copy the acl.auth.php into place if it doesn't exist. We don't want to manage
  # the file, as it is managed within the dokuwiki admin interface, but the file
  # is needed to get things running correctly initially.
  exec { 'install_config.acl.auth':
    command => "cp ${install_dir}/conf/acl.auth.php.dist ${install_dir}/conf/acl.auth.php",
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $www_owner,
    group   => $www_group,
    creates => "${install_dir}/conf/acl.auth.php",
    require => File[$install_dir],
  }

  # copy the users.auth.php into place if it doesn't exist. We don't want to manage
  # the file, as it is managed within the dokuwiki admin interface, but the file
  # is needed to get things running correctly initially.
  exec { 'install_users.auth':
    command => "cp ${install_dir}/conf/users.auth.php.dist ${install_dir}/conf/users.auth.php",
    path    => '/bin:/usr/bin:/usr/local/bin',
    user    => $www_owner,
    group   => $www_group,
    creates => "${install_dir}/conf/users.auth.php",
    require => File[$install_dir],
  }

  dokuwiki_user { $superuser:
    fullname     => 'Super User',
    password     => $superpassword,
    email        => $superemail,
    groups       => 'admin,user',
    instance_dir => $install_dir,
    require      => Exec['install_users.auth'],
  }

}
