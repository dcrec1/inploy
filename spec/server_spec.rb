require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do

  context "with server unicorn" do
    before :each do
      subject.server = :unicorn
      subject.user = @user = 'batman'
      subject.hosts = [@host = 'gothic']
      subject.application = @application = "robin"
      stub_commands
      mute subject
    end
    
    context "on local setup" do
      it "should create symbolic link" do
        expect_command "kill -USR2 `cat tmp/pids/unicorn.pid`"
        subject.local_setup
      end

      it_should_behave_like "local setup"
    end
  end
end