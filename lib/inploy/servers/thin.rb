module Inploy
  module Servers
    module Thin
      def restart_server
        run "thin --pid tmp/pids/thin.pid stop"
        run "thin --rackup config.ru --daemonize\
        --log log/thin.log --pid tmp/pids/thin.pid --environment production\
        --port 4500 start"
      end
    end
  end
end
