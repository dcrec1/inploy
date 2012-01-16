module Inploy
  module Templates
    module Rails3Push

      def remote_setup
        command = []
        command << "mkdir -p #{application_path}"
        command << "cd #{application_path}"
        command << "git init"
        command << "sed -i'' -e 's/master/#{branch}/' .git/HEAD" unless branch == 'master'
        command << "git config --bool receive.denyNonFastForwards false"
        command << "git config receive.denyCurrentBranch ignore"
        remote_run command.join(' && ')

        push_code

        command = []
        command << "cd #{application_path}"
        command << "#{rake_cmd} inploy:local:setup RAILS_ENV=#{environment} environment=#{environment}#{skip_steps_cmd}"
        remote_run command.join(' && ')
      end

      def remote_update
        push_code

        command = []
        command << "cd #{application_path}"
        command << "#{rake_cmd} inploy:local:update RAILS_ENV=#{environment} environment=#{environment}#{skip_steps_cmd}"
        remote_run command.join(' && ')
      end

      def install_gems
      end

      def update_code
      end

      private

      def push_code
        hosts.each do |host|
          run "git push -f #{user}@#{host}:#{application_path} #{branch}"
        end

        command = []
        command << "cd #{application_path}"
        command << "git reset --hard"
        command << "git clean -f -d -e public/system" # Keeps paperclip uploaded files
        command << "git submodule update --init"
        command << "bundle install --deployment" unless skip_step?('bundle_install')
        remote_run command.join(' && ')
      end

    end
  end
end
