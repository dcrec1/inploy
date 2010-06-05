require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::CLI do
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

  end
end
