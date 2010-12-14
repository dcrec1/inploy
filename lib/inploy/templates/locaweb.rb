module Inploy
  module Templates
    module Locaweb
      def self.extended(base)
        base.path = nil
      end

      def remote_setup
        run "rm -Rf #{tmp_path} && git clone . #{tmp_path} && tar czf - #{tmp_path} | ssh #{user}@#{host} 'tar xzfv - -C ~/ && mv ~#{tmp_path} #{path}/ && cd #{application_path} && rake inploy:local:setup RAILS_ENV=#{environment} environment=#{environment}'"
      end

      def remote_update
        run "git push ssh://[#{user}@#{host}#{port ? ":#{port}" : ''}]#{application_path} #{branch}"
        remote_run "cd #{application_path} && git checkout -f && rake inploy:local:update RAILS_ENV=#{environment} environment=#{environment}"
      end

      def local_setup
        super
        run "ln -s #{application_path}/public /home/#{user}/public_html/#{application}"
      end

      def local_update
        after_update_code
      end

      def path
        @path ||= "/home/#{user}/rails_app"
      end

      private

      def tmp_path
        "/tmp/#{application}"
      end
    end
  end
end
