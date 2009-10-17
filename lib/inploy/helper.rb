module Inploy
  module Helper
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
      log "mv #{src} #{dest}"
      FileUtils.cp src, dest unless File.exists?(dest)
    end

    def migrate_database
      rake "db:migrate RAILS_ENV=production"
    end

    def tasks
      `rake -T`
    end

    def rake_if_included(command)
      rake command if tasks.include?("rake #{command}")
    end

    def rake(command)
      run "rake #{command}"
    end

    def remote_run(command)
      hosts.each do |host|
        run "ssh #{user}@#{host} '#{command}'"
      end
    end

    def run(command)
      log command
      Kernel.system command
    end

    def log(command)
      puts "Inploy => #{command}"
    end

    def install_gems
      rake "gems:install"
    end
  end
end