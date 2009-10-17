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

FakeFS.activate!

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
