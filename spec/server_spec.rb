require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do

  before :each do
    subject.user = @user = 'batman'
    subject.hosts = [@host = 'gothic']
    subject.application = @application = "robin"
    stub_commands
    mute subject
  end

  context "with server unicorn" do
    before :each do
      subject.server = :unicorn
    end

    context "on local setup" do
      it "should restart the server" do
        expect_command "kill -USR2 `cat tmp/pids/unicorn.pid`"
        subject.local_setup
      end

      it_should_behave_like "local setup"
    end
  end

  context "with server thin" do
    before :each do
      subject.server = :thin
    end

    context "on local setup" do
      it "should restart the server" do
        expect_command("thin --pid tmp/pids/thin.pid stop").ordered
        expect_command("thin --rackup config.ru --daemonize\
        --log log/thin.log --pid tmp/pids/thin.pid --environment production\
        --port 4500 start").ordered
        subject.local_setup
      end
    end
  end

  context "with server mongrel" do
    before :each do
      subject.server = :mongrel
    end

    context "on local setup" do
      it "should restart the server" do
        expect_command "mongrel_cluster restart"
        subject.local_setup
      end
    end

  end

end
