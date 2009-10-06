module Inploy
  class Deploy
    attr_accessor :repository, :user, :application, :hosts, :path

    def path
      @path || '/opt'
    end

    def user
      @user || 'root'
    end

    def application_path
      "#{path}/#{application}"
    end

    def remote_setup
      remote_run "cd #{path} && sudo git clone #{repository} #{application} && sudo chown -R #{user} #{application}"
      remote_run "cd #{application_path} && rake inploy:local:setup"
    end

    def local_setup
      migrate_database
      run "mkdir -p tmp/pids"
      Dir.glob("config/*.sample").each do |file|
        secure_copy file, file.gsub(".sample", '')
      end
      run "./init.sh" if File.exists?("init.sh")
    end

    def remote_update
      remote_run "cd #{application_path} && rake inploy:update"
    end

    def local_update
      run "git pull origin master"
      migrate_database
      run "rm -R -f public/cache"
      rake_if_included "asset:packager:build_all"
      run "touch tmp/restart.txt"
    end

    private

    def secure_copy(src, dest)
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
      puts command
      Kernel.system command
    end
  end
end
