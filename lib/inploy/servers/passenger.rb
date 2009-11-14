module Inploy
  module Servers
    module Passenger
      def restart_server
        run "touch tmp/restart.txt"
      end
    end
  end
end