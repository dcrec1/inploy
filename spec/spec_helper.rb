$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'inploy'
require 'inploy/locaweb'
require 'spec'
require 'ruby-debug'
require 'fakefs'

shared_examples_for "remote update" do
  it "should run inploy:local:update task in the server" do
    expect_command "ssh #{@user}@#{@host} 'cd #{@path}/#{@application} && rake inploy:local:update'"
    subject.remote_update
  end
end

shared_examples_for "local update" do
  it "should run the migrations for production" do
    expect_command "rake db:migrate RAILS_ENV=production"
    subject.local_update
  end

  it "should restart the server" do
    expect_command "touch tmp/restart.txt"
    subject.local_update
  end

  it "should clean the public cache" do
    expect_command "rm -R -f public/cache"
    subject.local_update
  end

  it "should not package the assets if asset_packager exists" do
    dont_accept_command "rake asset:packager:build_all"
    subject.local_update
  end

  it "should package the assets if asset_packager exists" do
    subject.stub!(:tasks).and_return("rake acceptance rake asset:packager:build_all rake asset:packager:create_yml")
    expect_command "rake asset:packager:build_all"
    subject.local_update
  end

  it "should install gems" do
    expect_command "rake gems:install"
    subject.local_update
  end
end

FakeFS.activate!

def stub_tasks
  subject.stub!(:tasks).and_return("rake acceptance rake spec rake asset:packager:create_yml")
end

def mute(object)
  object.stub!(:puts)
end

def stub_commands
  Kernel.stub!(:system)
end

def expect_command(command)
  Kernel.should_receive(:system).with(command)
end

def dont_accept_command(command)
  Kernel.should_not_receive(:system).with(command)
end

def stub_file(file, result)
  File.stub!(:exists?).with(file).and_return(result)
end

def file_doesnt_exists(file)
  stub_file file, false
end

def file_exists(file, opts = {})
  File.open(file, 'w') { |f| f.write(opts[:content] || '') }
end

def path_exists(path)
  FileUtils.mkdir_p path
end
