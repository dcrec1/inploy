module Inploy
  class Locaweb < Deploy
    def remote_setup
      run "git clone . #{tmp_path} && tar czf - #{tmp_path} | ssh #{user}@#{host} 'tar xzfv - -C / && mv #{tmp_path} /home/#{user}/rails_app/ && cd /home/#{user}/rails_app/#{application} && rake inploy:local:setup'"
    end

    def remote_update
      run "git push ssh://[#{user}@#{host}]/home/#{user}/rails_app/#{application} master"
    end

    private

    def tmp_path
      "/tmp/#{application}"
    end

    def host
      hosts.first
    end
  end
end
