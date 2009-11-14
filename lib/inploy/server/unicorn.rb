module Inploy
  
  module Unicorn
    
    def restart_server
      run "kill -USR2 `cat tmp/pids/unicorn.pid`"
    end
    
  end
  
end