require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do

  context "with template rails3" do
    before :each do
      subject.template = :rails3
      subject.user = @user = 'batman'
      subject.hosts = [@host = 'gothic']
      subject.application = @application = "robin"
      subject.branch = @branch = 'branch'
      stub_commands
      mute subject
    end

    context "on install gems" do
      it "should execute bundle install ~/.bundle" do
        expect_command "bundle install ~/.bundle"
        subject.install_gems
      end
    end
  end
end
