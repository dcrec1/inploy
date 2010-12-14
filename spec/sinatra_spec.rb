require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do
  context "with template sinatra" do
    before :each do
      subject.template = :sinatra
      stub_commands
      mute subject
    end

    context "on local setup" do
      it "should ensure the public folder exists" do
        expect_command "mkdir -p public"
        subject.local_setup
      end
    end
  end
end
