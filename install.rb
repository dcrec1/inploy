require 'ftools'
src = File.join(File.dirname(__FILE__), "deploy.rb.sample")
dest = File.join(File.dirname(__FILE__), "..", "..", "..", "config", "deploy.rb.sample")
File.copy src, dest
