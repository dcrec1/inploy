require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Locaweb do

  context "configured" do
    before :each do
      subject.user = @user = 'batman'
      subject.hosts = [@host = 'gothic']
      subject.application = @application = "robin"
      mute subject
    end

    context "on remote setup" do
      it "should clone the repository with the application name and execute local setup" do
        expect_command "git clone . /tmp/#{@application} && tar czf - /tmp/#{@application} | ssh #{@user}@#{@host} 'tar xzfv - -C / && mv /tmp/#{@application} /home/#{@user}/rails_app/ && cd /home/#{@user}/rails_app/#{@application} && rake inploy:local:setup'"
        subject.remote_setup
      end
    end

    context "on remote update" do
      it "should push to the repository" do
        expect_command "git push ssh://[#{@user}@#{@host}]/home/#{@user}/rails_app/#{@application} master"
        subject.remote_update
      end
    end
  end
end
