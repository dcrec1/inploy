require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do

  subject { Inploy::Deploy.new }

  def expect_setup_with(branch, environment = 'production')
    if branch.eql? 'master'
      checkout = ""
    else
      checkout = "&& $(git branch | grep -vq #{branch}) && git checkout -f -b #{branch} origin/#{branch}"
    end
    expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path} && git clone --depth 1 #{@repository} #{@application} && cd #{@application} #{checkout} && bundle install --deployment --without development test cucumber && rake inploy:local:setup RAILS_ENV=#{environment} environment=#{environment}'"
  end

  context "with template rails3" do
    before :each do
      subject.template = :rails3
      subject.path = @path = "/fakie/path"
      subject.user = @user = 'batman'
      subject.hosts = [@host = 'gothic']
      subject.application = @application = "robin"
      subject.branch = @branch = 'branch'
      subject.environment = @environment = "production"
      stub_commands
      mute subject
    end

    context "on remote setup" do
      it "should clone the repository with the application name, checkout the branch, install gems from bundler and execute local setup" do
        expect_setup_with @branch, @environment
        subject.remote_setup
      end
    end

    context "on local update" do
      it "should not restart server if bundle fails" do
        expect_command("bundle install --deployment --without development test cucumber").and_return(false)
        dont_accept_command "touch tmp/restart.txt"
        subject.local_update
      end
    end

    context "on install gems" do
      it "should execute bundle install --deployment --without development test cucumber" do
        expect_command "bundle install --deployment --without development test cucumber"
        subject.install_gems
      end
    end
  end
end
