module Inploy
  class CLI
    def self.execute(params)
      deploy = Deploy.new
      case params.size
      when 0
        deploy.remote_update
      when 1
        deploy.send "remote_#{params.first}"
      when 2
        deploy.remote_install :from => params.last.sub("from=", "")
      end
    end
  end
end
