require "rubygems"
require "bundler"
Bundler.setup

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "inploy/configuration"

module Inploy
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Inploy::Configuration.new
    yield(configuration)
    initialize!
  end

  def self.initialize!
    unless Inploy::Configuration.initializers.nil?
      Inploy::Configuration.initializers.each { |initializer| initializer.call(self.configuration) }
    end
  end
end
