require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do
  
  def expect_setup_with(user, path)
    expect_command "ssh #{user}@#{@host} 'cd #{path} && git clone --depth 1 #{@repository} #{@application} && cd #{@application} && rake inploy:local:setup'"
  end

  it "should be extendable" do
    subject.template = :mouse_over_studio
    subject.remote_setup.should be_true
  end

  it "should return tasks as an string of rake tasks" do
    subject.instance_eval "def tasks_proxy; tasks; end"
    subject.tasks_proxy.should eql(`rake -T`)
  end

  context "configured" do
    before :each do
      subject.user = @user = 'batman'
      subject.hosts = [@host = 'gothic']
      subject.path = @path = '/city'
      subject.repository = @repository = 'git://'
      subject.application = @application = "robin"
      stub_commands
      mute subject
    end

    context "on remote setup" do
      it "should clone the repository with the application name and execute local setup" do
        expect_setup_with @user, @path
        subject.remote_setup
      end

      it "should dont execute init.sh if doesnt exists" do
        dont_accept_command "ssh #{@user}@#{@host} 'cd #{@path}/#{@application} && .init.sh'"
        subject.remote_setup
      end
    end

    context "on local setup" do
      it_should_behave_like "local setup"
    end

    context "on remote update" do
      it_should_behave_like "remote update"

      it "should exec the commands in all hosts" do
        subject.hosts = ['host0', 'host1', 'host2']
        3.times.each do |i|
          expect_command "ssh #{@user}@host#{i} 'cd #{@path}/#{@application} && rake inploy:local:update'"
        end
        subject.remote_update
      end
    end

    context "on local update" do
      it "should pull the repository" do
        expect_command "git pull origin master"
        subject.local_update
      end

      it_should_behave_like "local update"
    end
  end
end
