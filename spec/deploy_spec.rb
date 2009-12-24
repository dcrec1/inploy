require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do

  def expect_setup_with(branch, environment = 'production')
    if branch.eql? 'master'
      checkout = ""
    else
      checkout = "&& $(git branch | grep -vq #{branch}) && git checkout -f -b #{branch} origin/#{branch}"
    end
    expect_command "ssh #{@ssh_opts} #{@user}@#{@host} 'cd #{@path} && git clone --depth 1 #{@repository} #{@application} && cd #{@application} #{checkout} && rake inploy:local:setup environment=#{environment}'"
  end

  def setup(subject)
    mute subject
    stub_commands
    subject.user = @user = 'batman'
    subject.hosts = [@host = 'gothic']
    subject.path = @path = '/city'
    subject.repository = @repository = 'git://'
    subject.application = @application = "robin"
  end

  it "should include sudo when executing commands on the server" do
    mute subject
    expect_command "ls"
    subject.run "ls"

    expect_command "sudo ls"
    subject.sudo = true
    subject.run "ls"

    subject.sudo = false
  end

  it "should be extendable" do
    subject.template = :mouse_over_studio
    subject.remote_setup.should be_true
  end

  it "should return tasks as an string of rake tasks" do
    subject.instance_eval "def tasks_proxy; tasks; end"
    subject.tasks_proxy.should eql(`rake -T`)
  end

  it "should use master as default branch" do
    setup subject
    expect_setup_with "master"
    subject.remote_setup
  end

  it "should use production as default environment" do
    setup subject
    expect_command "rake db:migrate RAILS_ENV=production"
    subject.local_setup
  end

  it "should use production as the default environment" do
    subject.environment.should eql("production")
  end

  context "configured" do
    before :each do
      setup subject
			subject.ssh_opts = @ssh_opts = "-A"
			subject.branch = @branch = "onions"
			subject.environment = @environment = "staging"
    end

    context "on remote setup" do
      it "should clone the repository with the application name, checkout the branch and execute local setup" do
        expect_setup_with @branch, @environment
        subject.remote_setup
      end

      it "should not execute init.sh if doesnt exists" do
        dont_accept_command "ssh #{@user}@#{@host} 'cd #{@path}/#{@application} && .init.sh'"
        subject.remote_setup
      end
    end

    context "on local setup" do

      it "should use staging for the environment" do
        expect_command "rake db:migrate RAILS_ENV=staging"
        subject.local_setup
      end

      it_should_behave_like "local setup"
    end

    context "on remote update" do
      it_should_behave_like "remote update"

      it "should exec the commands in all hosts" do
        subject.hosts = ['host0', 'host1', 'host2']
        3.times.each do |i|
          expect_command "ssh #{@ssh_opts} #{@user}@host#{i} 'cd #{@path}/#{@application} && rake inploy:local:update environment=#{@environment}'"
        end
        subject.remote_update
      end
    end

    context "on local update" do
      it "should pull the repository" do
        expect_command "git pull origin #{@branch}"
        subject.local_update
      end

      it_should_behave_like "local update"
    end
  end
end
