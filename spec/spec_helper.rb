$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'inploy'
require 'inploy/cli'
require 'spec'
require 'ruby-debug'
require 'fakefs'

require 'shared_examples'

FakeFS.activate!

def stub_tasks(object = subject)
  object.stub!(:tasks).and_return("rake acceptance rake spec rake hoptoad:deploy rake asset:packager:create_yml")
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

def file_doesnt_exists(file)
  File.delete file rescue nil
end

def file_exists(file, opts = {})
  File.open(file, 'w') { |f| f.write(opts[:content] || '') }
end

def path_exists(path)
  FileUtils.mkdir_p path
end
