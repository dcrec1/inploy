module Inploy
  module Templates
    module Rails3
      def install_gems
        run "bundle install ~/.bundle"
      end
    end
  end
end
