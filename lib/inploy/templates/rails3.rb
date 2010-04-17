module Inploy
  module Templates
    module Rails3
      def remote_setup
        if branch.eql? "master"
          checkout = ""
        else
          checkout = "&& $(git branch | grep -vq #{branch}) && git checkout -f -b #{branch} origin/#{branch}"
        end
        remote_run "cd #{path} && #{@sudo}git clone --depth 1 #{repository} #{application} && cd #{application} #{checkout} && bundle install ~/.bundle && #{@sudo}rake inploy:local:setup environment=#{environment}"
      end

      def install_gems
        run "bundle install ~/.bundle"
      end
    end
  end
end
