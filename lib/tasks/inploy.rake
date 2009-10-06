def deploy
  @deploy ||= Inploy::Deploy.new
end

require "config/deploy.rb"

namespace :inploy do

  desc "Setup"
  task :setup do
    deploy.setup
  end

  desc "Deploy"
  task :deploy do
    deploy.remote_update
  end

  desc "Update"
  task :update do
    deploy.update
  end
end
