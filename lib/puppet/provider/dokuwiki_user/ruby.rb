require 'pathname'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','..','puppet_x','dokuwiki','helper.rb'))

Puppet::Type.type(:dokuwiki_user).provide(:ruby) do

  confine :osfamily => [:redhat, :debian]
  commands :find => 'find', :openssl => 'openssl'

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def fullname
    @property_hash[:fullname]
  end

  def fullname=(value)
    @property_flush[:fullname] = value
  end

  def email
    @property_hash[:email]
  end

  def email=(value)
    @property_flush[:email] = value
  end

  def password
    @property_hash[:password]
  end

  def password=(value)
    @property_flush[:password] = value
  end

  def groups
    @property_hash[:groups]
  end

  def groups=(value)
    @property_flush[:groups] = value
  end

  def instance_dir
    @property_hash[:instance_dir]
  end

  def instance_dir=(value)
    @property_flush[:instance_dir] = value
  end

  def create
    Puppet.debug("creating new dokuwiki_user resource")
    instance_dir = ''
    login = resource[:name]
    password = ''
    fullname = ''
    email = ''
    groups = ''
    if(resource[:fullname]) then
      fullname = resource[:fullname]
    end
    if(resource[:password]) then
      password = resource[:password]
    end
    if(resource[:email]) then
      email = resource[:email]
    end
    if(resource[:groups]) then
      groups = resource[:groups]
    end
    if(resource[:instance_dir]) then
      instance_dir = resource[:instance_dir]
      if !File.directory?(instance_dir) then
        fail("#{instance_dir} does not exist")
      end
    else
      # get the first install found -- that's the default if not specified
      instances = Dokuwiki::Helper.find_installs
      if instances.length == 0 then
        fail('unable to find a dokuwiki instance')
      end
      instance_dir = instances[0]
    end

    authfile = File.join(instance_dir,'conf','users.auth.php')

    line = "#{login}:#{password}:#{fullname}:#{email}:#{groups}"
    File.open(authfile, 'a') do |file|
      file.puts line
    end
  end

  def destroy
    require 'tempfile'
    require 'fileutils'

    login = resource[:name]
    instance_dir = resource[:instance_dir] || @property_hash[:instance_dir]
    authfile = File.join(instance_dir,'conf','users.auth.php')
    tmp = Tempfile.new('auth')
    open(authfile, 'r') do |f|
      f.each_line do |line|
         tmp.write(line) unless line.start_with? "#{login}:"
      end
    end
    FileUtils.mv tmp.path, authfile
  end

  def flush
    if(@property_flush.length > 0) then
      Puppet.debug("flushing dokuwiki_user information to auth file")
      login = resource[:name]
      password = resource[:password] || @property_hash[:password]
      fullname = resource[:fullname] || @property_hash[:fullname]
      email = resource[:email] || @property_hash[:email]
      groups = resource[:groups] || @property_hash[:groups]
      instance_dir = resource[:instance_dir] || @property_hash[:instance_dir]

      line = "#{login}:#{password}:#{fullname}:#{email}:#{groups}"
      authfile = File.join(instance_dir,'conf','users.auth.php')
      searchstr = "^#{login}:.*$"
      text = File.read(authfile)
      content = text.gsub(/#{searchstr}/, line)
      File.open(authfile, "w") { |file| file << content }
    end
    @property_hash = resource.to_hash

  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.prefetch(resources)
    users = instances
    resources.keys.each do | name |
      if provider = users.find{ | user | user.name == name }
        resources[name].provider = provider
      end
    end
  end

  def self.find_installs
    installs = Array.new
    dokufiles = find('/','-type','f','-name','doku.php').split("\n")
    dokufiles.each do |doku|
      path = Pathname.new(doku)
      installs << path.dirname
    end
    return installs
  end

  def self.instances
    users = Array.new
    installs = Dokuwiki::Helper.find_installs
    # iterate over each install found
    installs.each do |parent|
      authfile = File.join(parent,'conf','users.auth.php')
      if File.exist?(authfile) then
        File.open(authfile).each_line do |line|
          line.chomp!
          next if line.empty? || line =~ /^#/
          (name,password,fullname,email,groups) = line.split(':')
          users << new(
            :ensure        => :present,
            :name          => name,
            :password      => password,
            :fullname      => fullname,
            :email         => email,
            :groups        => groups,
            :instance_dir  => parent
          )
        end
      end
    end
    return users
  end

end
