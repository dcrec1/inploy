module Inploy
  class Deploy
    attr_accessor :repository, :user, :application, :hosts, :path

    def path
      @path || '/opt'
    end

    def user
      @user || 'root'
    end

    def setup
      remote_run "cd #{path} && sudo git clone #{repository} #{application} && sudo chown -R #{user} #{application}"
    end

    def application_path
      "#{path}/#{application}"
    end

    def remote_update
      remote_run "cd #{application_path} && rake inploy:update"
    end

    def update
      run "git pull origin master"
      rake "db:migrate RAILS_ENV=production"
      run "rm -R -f public/cache"
      rake_if_included "asset:packager:build_all"
      run "touch tmp/restart.txt"
    end

    private

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
