require 'fileutils'
src = File.join(File.dirname(__FILE__), "deploy.rb.sample")
dest = File.join(File.dirname(__FILE__), "..", "..", "..", "config", "deploy.rb")
FileUtils.copy src, dest unless File.exists?(dest)