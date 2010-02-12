module Inploy
  class Deploy
    include Helper
    include DSL
    attr_accessor :repository, :user, :application, :hosts, :path, :ssh_opts, :branch, :environment, :port

    def initialize
      self.server = :passenger
      @branch = 'master'
      @environment = 'production'
      @sudo = ''
    end

    def template=(template)
      load_module("templates/#{template}")
    end

    def server=(server)
      load_module("servers/#{server}")
    end

    def sudo=(value)
      @sudo = value.equal?(true) ? 'sudo ' : ''
    end

    def remote_setup
      if branch.eql? "master"
        checkout = ""
      else
        checkout = "&& $(git branch | grep -vq #{branch}) && git checkout -f -b #{branch} origin/#{branch}"
      end
      remote_run "cd #{path} && #{@sudo}git clone --depth 1 #{repository} #{application} && cd #{application} #{checkout} && #{@sudo}rake inploy:local:setup environment=#{environment}"
    end

    def local_setup
      create_folders 'tmp/pids', 'db'
      rake "db:create RAILS_ENV=#{environment}"
      run "./init.sh" if File.exists?("init.sh")
      after_update_code
    end

    def remote_update
      remote_run "cd #{application_path} && #{@sudo}rake inploy:local:update environment=#{environment}"
    end

    def local_update
      run "git pull origin #{branch}"
      after_update_code
    end

    def before_restarting_server(&block)
     @before_restarting_server = block
    end

    private

    def after_update_code
      run "git submodule update --init"
      copy_sample_files
      install_gems
      migrate_database
      run "whenever --update-crontab #{application} --set 'environment=#{environment}'" if File.exists?("config/schedule.rb")
      run "rm -R -f public/cache"
      run "rm -R -f public/assets" if jammit_is_installed?
      rake_if_included "more:parse"
      rake_if_included "asset:packager:build_all"
      rake_if_included "hoptoad:deploy TO=#{environment} REPO=#{repository} REVISION=#{`git log | head -1 | cut -d ' ' -f 2`}"
      ruby_if_exists "vendor/plugins/newrelic_rpm/bin/newrelic_cmd", :params => "deployments"
      instance_eval(&@before_restarting_server) unless @before_restarting_server.nil?
      restart_server
    end
  end
end
