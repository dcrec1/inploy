module Inploy
  module Helper
    def load_module(filename)
      require "inploy/#{filename}"
      extend eval(filename.split("/").map { |word| camelize(word) }.join("::"))
    end
    
    def create_folders(*folders)
      folders.each { |folder| create_folder folder }
    end

    def create_folder(path)
      run "mkdir -p #{path}"
    end

    def host
      hosts.first
    end

    def camelize(string)
      string.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
    end

    def application_path
      "#{path}/#{application}"
    end

    def copy_sample_files
      Dir.glob("config/*.sample").each do |file|
        secure_copy file, file.gsub(".sample", '')
      end
    end

    def secure_copy(src, dest)
      unless File.exists?(dest)
        log "mv #{src} #{dest}"
        FileUtils.cp src, dest
      end
    end

    def migrate_database
      rake "db:migrate RAILS_ENV=#{environment}"
    end

    def tasks
      `rake -T`
    end

    def rake_if_included(command)
      rake command if tasks.include?("rake #{command.split[0]}")
    end

    def rake(command)
      run "rake #{command}"
    end

    def remote_run(command)
      hosts.each do |host|
        run "ssh #{ssh_opts} #{user}@#{host} '#{command}'", true
      end
    end

    def run(command, disable_sudo = false)
      log command
      
      if disable_sudo
        Kernel.system command
      else
        Kernel.system "#{@sudo}#{command}"
      end
    end

    def log(command)
      puts "Inploy => #{command}"
    end

    def install_gems
      rake "gems:install RAILS_ENV=#{environment}"
    end
  end
end
