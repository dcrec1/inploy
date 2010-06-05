require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::Deploy do

  context "with template rails3_push" do
    before :each do
      subject.template = :rails3_push
      subject.path = @path = "/fakie/path"
      subject.user = @user = 'batman'
      subject.hosts = [@host = 'gothic']
      subject.application = @application = "robin"
      subject.branch = @branch = 'live'
      subject.environment = @environment = "production"
      stub_commands
      mute subject
    end

    context "on remote setup" do
      it "should init and configure an empty repository, push to it and run the local setup" do
        expect_command "ssh #{@ssh_opts} batman@gothic 'mkdir -p /fakie/path/robin && cd /fakie/path/robin && git init && sed -i'' -e 's/master/live/' .git/HEAD && git config --bool receive.denyNonFastForwards false && git config receive.denyCurrentBranch ignore'"
        expect_command "git push -f batman@gothic:/fakie/path/robin live"
        expect_command "ssh #{@ssh_opts} batman@gothic 'cd /fakie/path/robin && git reset --hard && git clean -f -d && git submodule update --init && bundle install'"
        expect_command "ssh #{@ssh_opts} batman@gothic 'cd /fakie/path/robin && rake inploy:local:setup environment=production'"
        subject.remote_setup
      end
    end

    context "on remote update" do
      it_should_behave_like "remote update"

      it "should push git repository and runs the local update on all hosts" do
        subject.hosts = ['host0', 'host1', 'host2']
        3.times.each do |i|
          expect_command "git push -f batman@host#{i}:/fakie/path/robin live"
          expect_command "ssh #{@ssh_opts} batman@host#{i} 'cd /fakie/path/robin && git reset --hard && git clean -f -d && git submodule update --init && bundle install'"
          expect_command "ssh #{@ssh_opts} batman@host#{i} 'cd /fakie/path/robin && rake inploy:local:update environment=production'"
        end
        subject.remote_update
      end
    end

    context "on install gems" do
      it "should not install gems (install_gems is called from rake, but rake already requires bundles)" do
        dont_accept_command "bundle install"
        dont_accept_command "rake gems:install RAILS_ENV=production"
        subject.install_gems
      end
    end

    context "on update code" do
      it "should not git pull" do
        dont_accept_command "git pull origin live"
        subject.update_code
      end
    end
  end
end
