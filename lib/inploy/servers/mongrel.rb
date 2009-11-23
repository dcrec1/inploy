module Inploy
  module Servers
    module Mongrel
      def restart_server
        run "mongrel_cluster restart"
      end
    end
  end
end
