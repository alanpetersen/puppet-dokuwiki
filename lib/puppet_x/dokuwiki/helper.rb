module Dokuwiki

  class Helper

    def self.find_installs
      installs = Array.new
      dokufiles = `find / -type f -name doku.php`.split("\n")
      dokufiles.each do |doku|
        path = Pathname.new(doku)
        installs << path.dirname
      end
      return installs
    end

    def self.find_userhash(login)
      installs = find_installs
      installs.each do |parent|
        authfile = File.join(parent,'conf','users.auth.php')
        if File.exist?(authfile) then
          File.open(authfile).each_line do |line|
            line.chomp!
            next if line.empty? || !(line =~ /^#{login}:/)
            (name,password_hash,fullname,email,groups) = line.split(':')
            return password_hash
          end
        end
      end
      return nil
    end

    def self.hash_password(salt, password)
      if salt && salt.length > 0
        return `openssl passwd -1 -salt #{salt} #{password}`.chomp!
      else
        return `openssl passwd -1 #{password}`.chomp!
      end
    end

    def self.generate_hash(login, password)
      salt = nil
      userhash = find_userhash(login)
      if(userhash && userhash.length > 0) then
        (empty,type,salt,hash) = userhash.split('$')
      end
      return hash_password(salt, password)
    end

  end

end
