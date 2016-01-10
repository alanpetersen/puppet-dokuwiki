# dokuwiki

#### Table of Contents

1. [Overview](#overview)
1. [Usage - Basic usage information for the module](#usage)
1. [Reference - Custom types used by the module](#reference)
1. [Limitations - What the module supports](#limitations)

## Overview

This module manages a dokuwiki instance. DokuWiki is a simple to use and highly versatile Open Source wiki software that doesn't require a database. More information can be found at the Dokuwiki website: [https://www.dokuwiki.org](https://www.dokuwiki.org).

## Usage

This module does not manage the webserver that servers up the wiki... you need to manage that yourself. The module also does not manage PHP, that must be managed separately.

At a minimum, when using the dokuwiki class you should specify the wiki_title and install_dir parameters. These can be done in a typical class declaration:

~~~
class { 'dokuwiki':
	wiki_title  => 'My First Wiki',
	install_dir => '/opt/www/dokuwiki',
}
~~~

### Class Parameters

* `install_dir`    - directory that the Dokuwiki instance can be reached. Since the Dokuwiki tarball expands into a directory with the version number, the install_dir will be a symbolic link that points to the actual extraction. This defaults to `/opt/www/dokuwiki`.
* `download_url`   - the URL from which the Dokuwiki distribution is retrieved. By default, this is the latest stable version: [http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz](http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz).
* `version`        - the version of Dokuwiki that will be installed. This parameter is required if you do not specify 'autolink'.
* `autolink`       - a boolean `true|false` indicating whether or not the version should be automatically determined (via the `$DOKUWIKI/VERSION` file). This defaults to `true`. If set to `false`, then the `version` parameter must also be set.
* `www_owner`      - the OS user that will own the extracted directory and symlink.
* `www_group`      - the OS group that will own the extracted directory and symlink.
* `htaccess       - the location of the htaccess file to install. By default, this is set to `puppet:///modules/dokuwiki/htaccess`.
* `wiki_title`     - the title for the wiki.
* `license`        - Defaults to `cc-by-sa`. Supported licenses are:
	* cc-zero       - CC0 1.0 Universal [http://creativecommons.org/publicdomain/zero/1.0/](http://creativecommons.org/publicdomain/zero/1.0/)
	* publicdomain  - Public Domain [http://creativecommons.org/licenses/publicdomain/](http://creativecommons.org/licenses/publicdomain/)
	* cc-by         - CC Attribution 3.0 Unported [http://creativecommons.org/licenses/by/3.0/](http://creativecommons.org/licenses/by/3.0/)
	* cc-by-sa      - CC Attribution-Share Alike 3.0 Unported [http://creativecommons.org/licenses/by-sa/3.0/](http://creativecommons.org/licenses/by-sa/3.0/)
	* gnufdl        - GNU Free Documentation License 1.3 [http://www.gnu.org/licenses/fdl-1.3.html](http://www.gnu.org/licenses/fdl-1.3.html)
	* cc-by-nc      - CC Attribution-Noncommercial 3.0 Unported [http://creativecommons.org/licenses/by-nc/3.0/](http://creativecommons.org/licenses/by-nc/3.0/)
	* cc-by-nc-sa   - CC Attribution-Noncommercial-Share Alike 3.0 Unported [http://creativecommons.org/licenses/by-nc-sa/3.0/](http://creativecommons.org/licenses/by-nc-sa/3.0/)
* `language`       - the language setting for the wiki. Defaults to `en`.
* `useacl`         - a flag indicating whether or not to use access control lists. Defaults to `'1'`
* `superuser`      - the username for the superuser (admin) local Dokuwiki account. Defaults to `admin`.
* `superpassword`  - the password for the superuser (admin) local Dokuwiki account. Defaults to `password`.
* `superemail`     - the email address for the superuser (admin) local Dokuwiki account. Defaults to `admin@host.com`.
* `disableactions` - an array of which actions to disable. Defaults to `['register']` which prevents users from registering themselves.
* `authad`         - a flag `[0,1]` indicating whether AD authentication is enabled. Currently unsupported and set to `0`.
* `authldap`       - a flag `[0,1]` indicating whether LDAP authentication is enabled. Currently unsupported and set to `0`.
* `authmysql`      - a flag `[0,1]` indicating whether Mysql authentication is enabled. Currently unsupported and set to `0`.
* `authpgsql`      - a flag `[0,1]` indicating whether PostgreSQL authentication is enabled. Currently unsupported and set to `0`.


### Example usage:

~~~
$install_dir = '/opt/www/dokuwiki'
class { 'apache':
	mpm_module => 'prefork',
}
class { 'apache::mod::php': }
apache::vhost { $::fqdn:
	docroot        => $install_dir,
	manage_docroot => false,
	port           => '80',
	override       => 'All',
}
class { 'dokuwiki':
	install_dir => $install_dir,
	wiki_title => 'My First Wiki',
}
~~~

## Reference

The `dokuwiki_user` custom type provides a mechanism for managing users in the `users.auth.php` file.

For example, to manage a user account `jschmoe` on the node, you can do the following:

~~~
dokuwiki_user { 'jschmoe':
	fullname     => 'Joe Schmoe',
	password     => 'secretpassword',
	email        => 'jschmoe@host.com',
	groups       => 'user',
}
~~~

On the node, the `puppet resource` command can be used to manage dokuwiki_user resources. For example, `puppet resource dokuwiki_user` will list all the Dokuwiki users.


## Limitations

Although various authentication mechanisms (LDAP, AD, MySQL, PostgreSQL) can be used with Dokuwiki, this module currenly only supports using built-in authentication. User entries are stored in the `$DOKUWIKI/conf/users.auth.php` file.

