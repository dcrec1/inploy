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
        deploy.send "remote_#{params.first}", parse(params.last)
      end
    end

    private

    def self.parse(param)
      if param.include? '='
        keys = param.split "="
        { keys.first.to_sym => keys.last }
      else
        param
      end
    end
  end
end
