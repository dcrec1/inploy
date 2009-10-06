require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def expect_command(command)
  Kernel.should_receive(:system).with(command)
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
end
