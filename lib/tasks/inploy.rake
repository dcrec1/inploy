require File.expand_path(File.dirname(__FILE__) + '/../inploy')

def deploy
  @deploy ||= Inploy::Deploy.new
end

require "config/deploy.rb"

namespace :inploy do

  desc "Setup"
  task :setup do
    deploy.remote_setup
  end

  desc "Deploy"
  task :deploy do
    deploy.remote_update
  end

  desc "Update"
  task :update do
    deploy.local_update
  end

  namespace :local do
    desc "Local Setup"
    task :setup do
      deploy.local_setup
    end
  end
end
