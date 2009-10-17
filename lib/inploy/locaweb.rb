module Inploy
  module Locaweb
    def remote_setup
      run "git clone . #{tmp_path} && tar czf - #{tmp_path} | ssh #{user}@#{host} 'tar xzfv - -C / && mv #{tmp_path} #{path}/ && cd #{path}/#{application} && rake inploy:local:setup'"
    end

    def remote_update
      run "git push ssh://[#{user}@#{host}]/home/#{user}/rails_app/#{application} master"
    end

    private
    
    def path
      @path ||= "/home/#{user}/rails_app"
    end

    def tmp_path
      "/tmp/#{application}"
    end
  end
end
