require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def stub_commands
  Kernel.stub!(:system)
end

def expect_command(command)
  Kernel.should_receive(:system).with(command)
end

def dont_accept_command(command)
  Kernel.should_not_receive(:system).with(command)
end

def expect_setup_with(user, path)
  expect_command "ssh #{user}@#{@host} 'cd #{path} && sudo git clone #{@repository} #{@application} && sudo chown -R #{user} #{@application}'"
end

describe Inploy::Deploy do
  before :each do
    @object = Inploy::Deploy.new
    @object.user = @user = 'batman'
    @object.hosts = [@host = 'gothic']
    @object.path = @path = '/city'
    @object.repository = @repository = 'git://'
    @object.application = @application = "robin"
  end

  it "should do the setup cloning the repository with the application name" do
    expect_command "ssh #{@user}@#{@host} 'cd #{@path} && sudo git clone #{@repository} #{@application} && sudo chown -R #{@user} #{@application}'"
    @object.setup
  end

  it "should take /opt as the default path" do
    @object.path = nil
    expect_setup_with @user, '/opt'
    @object.setup
  end

  it "should take root as the default user" do
    @object.user = nil
    expect_setup_with 'root', @path
    @object.setup
  end

  it "should do a remote update running the inploy:update task" do
    expect_command "ssh #{@user}@#{@host} 'cd #{@path}/#{@application} && rake inploy:update'"
    @object.remote_update
  end

  it "should exec the commands in all hosts" do
    @object.hosts = ['host0', 'host1', 'host2']
    3.times.each do |i|
      expect_command "ssh #{@user}@host#{i} 'cd #{@path}/#{@application} && rake inploy:update'"
    end
    @object.remote_update
  end

  context "on update" do
    before :each do
      stub_commands
    end

    it "should pull the repository" do
      expect_command "git pull origin master"
      @object.update
    end

    it "should run the migrations for production" do
      expect_command "rake db:migrate RAILS_ENV=production"
      @object.update
    end

    it "should restart the server" do
      expect_command "touch tmp/restart.txt"
      @object.update
    end

    it "should clean the public cache" do
      expect_command "rm -R -f public/cache"
      @object.update
    end

    it "should not package the assets if asset_packager exists" do
      dont_accept_command "rake asset:packager:build_all"
      @object.update
    end

    it "should package the assets if asset_packager exists" do
      @object.stub!(:tasks).and_return("rake acceptance rake asset:packager:build_all rake asset:packager:create_yml")
      expect_command "rake asset:packager:build_all"
      @object.update
    end
  end
end
