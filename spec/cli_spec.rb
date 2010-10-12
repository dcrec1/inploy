require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::CLI do

  subject { Inploy::CLI.new }

  context "on execute" do
    before :each do
      Inploy::Deploy.stub!(:new).and_return(@deploy = mock(Object))
    end

    it "should execute deploy.remote_update when params are empty" do
      @deploy.should_receive(:remote_update)
      subject.class.execute []
    end

    it "should execute deploy.remote_update when params = ['update']" do
      @deploy.should_receive(:remote_update)
      subject.class.execute %w(update)
    end

    it "should execute deploy.remote_setup when params = ['setup']" do
      @deploy.should_receive(:remote_setup)
      subject.class.execute %w(setup)
    end

    it "should execute deploy.remote_install :from => url when params = ['install', 'from=url']" do
      @deploy.should_receive(:remote_install).with(:from => 'url')
      subject.class.execute %w(install from=url)
    end

    it "should execute deploy.remote_rake task when params = ['rake', 'task']" do
      @deploy.should_receive(:remote_rake).with('db:migrate')
      subject.class.execute %w(rake db:migrate)
    end

    it "should execute deploy.remote_reset :to => commit when params = ['reset', 'to=commit']" do
      @deploy.should_receive(:remote_reset).with(:to => '12345')
      subject.class.execute %w(reset to=12345)
    end
  end
end
