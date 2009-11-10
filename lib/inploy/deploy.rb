module Inploy
  class Deploy
    include Helper

    attr_accessor :repository, :user, :application, :hosts, :path, :ssh_opts, :branch, :environment

    def initialize
      @branch = 'master'
      @environment = 'production'
    end

    def template=(template)
      require "inploy/#{template}"
      extend eval(camelize(template))
    end

    def remote_setup
      if branch.eql? "master"
        checkout = ""
      else
        checkout = "&& $($(git branch | grep -vq #{branch}) && git checkout -f -b #{branch} origin/#{branch})"
      end
      remote_run "cd #{path} && git clone --depth 1 #{repository} #{application} && cd #{application} #{checkout} && rake inploy:local:setup environment=#{environment}"
    end

    def local_setup
      create_folders 'tmp/pids', 'db'
      run "./init.sh" if File.exists?("init.sh")
      after_update_code
    end

    def remote_update
      remote_run "cd #{application_path} && rake inploy:local:update environment=#{environment}"
    end

    def local_update
      run "git pull origin #{branch}"
      after_update_code
    end

    private

    def after_update_code
      run "git submodule update --init"
      copy_sample_files
      install_gems
      migrate_database
      run "rm -R -f public/cache"
      rake_if_included "more:parse"
      rake_if_included "asset:packager:build_all"
      rake_if_included "hoptoad:deploy TO=#{environment} REPO=#{repository} REVISION=#{`git log | head -1 | cut -d ' ' -f 2`}"
      run "touch tmp/restart.txt"
    end
  end
end
