module Inploy
  class Deploy
    include Helper
    include DSL

    attr_accessor :repository, :user, :application, :hosts, :path, :app_folder, :ssh_opts, :branch, :environment, :port, :skip_steps, :cache_dirs, :sudo, :login_shell, :bundler_opts

    define_callbacks :before_git, :after_git, :after_setup, :before_restarting_server

    def initialize
      self.server = :passenger
      @cache_dirs = %w(public/cache)
      @branch = 'master'
      @environment = 'production'
      @user = "deploy"
      @path = "/var/local/apps"
      @app_folder = nil
      configure
    end

    def template=(template)
      load_module "templates/#{template}"
    end

    def server=(server)
      load_module "servers/#{server}"
    end

    def configure
      configure_from configuration_file if configuration_file
    end

    def configure_from(file)
      deploy = self
      eval file.read + ';local_variables.each { |variable| deploy.send "#{variable}=", eval(variable.to_s) rescue nil }'
    end

    def remote_install(opts)
      remote_run "bash < <(wget -O- #{opts[:from]})"
    end

    def remote_setup
      remote_run "cd #{path} && #{sudo_if_should}git clone --depth 1 #{repository} #{application} && cd #{application_folder} #{checkout}#{bundle} && #{sudo_if_should}#{rake_cmd} inploy:local:setup RAILS_ENV=#{environment} environment=#{environment}#{skip_steps_cmd}"
    end

    def local_setup
      create_folders 'public', 'tmp/pids', 'db'
      callback :after_git
      copy_sample_files
      rake "db:create RAILS_ENV=#{environment}"
      run "./init.sh" if file_exists?("init.sh")
      after_update_code
      callback :after_setup
    end

    def remote_update
      remote_run "cd #{application_path} && #{sudo_if_should}#{rake_cmd} inploy:local:update RAILS_ENV=#{environment} environment=#{environment}#{skip_steps_cmd}"
    end

    def remote_rake(task)
      remote_run "cd #{application_path} && #{rake_cmd} #{task} RAILS_ENV=#{environment}"
    end

    def remote_reset(params)
      callback :before_git
      remote_run "cd #{application_path} && git reset --hard #{params[:to]}"
      callback :after_git
    end

    def local_update
      update_code
      after_update_code
    end

    def update_code
      callback :before_git
      run "git pull origin #{branch}"
      callback :after_git
    end

    private

    def checkout
      branch.eql?("master") ? "" : "&& git checkout -f -b #{branch} origin/#{branch}"
    end

    def bundle
      " && #{bundle_cmd}" if using_bundler?
    end

    def after_update_code
      run "cd #{path}/#{application} && git submodule update --init && cd #{path}/#{application}/#{app_folder}"
      copy_sample_files
      return unless install_gems
      migrate_database
      update_crontab
      run "rm -R -f public/assets" if jammit_is_installed?
      run "RAILS_ENV=#{environment} script/delayed_job restart" if file_exists?("script/delayed_job")
      rake_if_included "more:parse"
      run "compass compile" if file_exists?("config/compass.rb")
      rake_if_included "barista:brew"
      rake_if_included "asset:packager:build_all"
      rake_if_included "hoptoad:deploy RAILS_ENV=#{environment} TO=#{environment} REPO=#{repository} REVISION=#{`git log | head -1 | cut -d ' ' -f 2`}"
      notify_new_relic
      callback :before_restarting_server
      restart_server
      clear_cache
    end
  end
end
