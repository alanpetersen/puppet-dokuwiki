require File.expand_path(File.join(File.dirname(__FILE__),'..','..','puppet_x','dokuwiki','helper.rb'))

Puppet::Type.newtype(:dokuwiki_user) do
  desc <<-'ENDOFDESC'
  A resource to manage dokuwiki users.

  The provider will attempt to locate the dokuwiki installation and set the entries
  in the users.auth.php file as appropriate. If there is more than one dokuwiki install
  on the node, it is recommended to explicitly supply the instance_dir attribute.

  Passwords can be given as either raw values (e.g. perhaps retrieved from hiera) or
  as encrypted strings. Dokuwiki uses SMD5 hashes by default, so

  Example usage:

  dokuwiki_user { 'admin':
    fullname     => 'System Administrator',
    email        => 'admin@host.com',
    password     => 'supersecret',
    groups       => 'user,admin',
    instance_dir => '/opt/www/dokuwiki',
  }

  ENDOFDESC

  ensurable

  newparam(:name, :namevar => true) do
   desc "Login name - must be unique"
   newvalues(/\w*/)
  end

  newproperty(:fullname) do
    desc "The user's real name"
  end

  newproperty(:email) do
    desc "The user's email address"
  end

  newproperty(:password) do
    desc "The user's unencrypted password"
    munge do |value|
      if(!value.start_with?("$1$")) then
        Dokuwiki::Helper.generate_hash(@resource[:name], value)
      else
        value
      end
    end
  end

  newproperty(:groups) do
    desc "A comma-separated list of groups"
    defaultto :user
  end

  newproperty(:instance_dir) do
    desc "The path to the instance's dokuwiki directory"
  end

end
