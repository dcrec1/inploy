module Inploy
  class Deploy
    include Helper
    include DSL

    attr_accessor :repository, :user, :application, :hosts, :path, :ssh_opts, :branch, :environment,
                  :port, :skip_steps, :cache_dirs, :sudo

    def initialize
      self.server = :passenger
      @cache_dirs = %w(public/cache)
      @branch = 'master'
      @environment = 'production'
      @user = "deploy"
      @path = "/var/local/apps"
      configure
    end

    def template=(template)
      load_module "templates/#{template}"
    end

    def server=(server)
      load_module "servers/#{server}"
    end

    def configure
      if file = configuration_file
        deploy = self
        eval file.read
        local_variables.each do |variable|
          send "#{variable}=", eval(variable) rescue nil
        end
      end
    end

    def remote_install(opts)
      remote_run "bash < <(wget -O- #{opts[:from]})"
    end

    def remote_setup
      if branch.eql? "master"
        checkout = ""
      else
        checkout = "&& $(git branch | grep -vq #{branch}) && git checkout -f -b #{branch} origin/#{branch}"
      end
      remote_run "cd #{path} && #{@sudo}git clone --depth 1 #{repository} #{application} && cd #{application} #{checkout} && #{@sudo}rake inploy:local:setup environment=#{environment}#{skip_steps_cmd}"
    end

    def local_setup
      create_folders 'tmp/pids', 'db'
      copy_sample_files
      rake "db:create RAILS_ENV=#{environment}"
      run "./init.sh" if File.exists?("init.sh")
      after_update_code
    end

    def remote_update
      remote_run "cd #{application_path} && #{@sudo}rake inploy:local:update environment=#{environment}#{skip_steps_cmd}"
    end

    def local_update
      update_code
      after_update_code
    end

    def before_restarting_server(&block)
      @before_restarting_server = block
    end

    def update_code
      run "git pull origin #{branch}"
    end

    private

    def after_update_code
      run "git submodule update --init"
      copy_sample_files
      install_gems
      migrate_database
      update_crontab
      clear_cache
      run "rm -R -f public/assets" if jammit_is_installed?
      rake_if_included "more:parse"
      rake_if_included "asset:packager:build_all"
      rake_if_included "hoptoad:deploy RAILS_ENV=#{environment} TO=#{environment} REPO=#{repository} REVISION=#{`git log | head -1 | cut -d ' ' -f 2`}"
      ruby_if_exists "vendor/plugins/newrelic_rpm/bin/newrelic_cmd", :params => "deployments"
      instance_eval(&@before_restarting_server) unless @before_restarting_server.nil?
      restart_server
    end
  end
end
