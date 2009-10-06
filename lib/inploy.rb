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

    private

    def remote_run(command)
      hosts.each do |host|
        execute "ssh #{user}@#{host} '#{command}'"
      end
    end

    def execute(command)
      puts command
      Kernel.system command
    end
  end
end
