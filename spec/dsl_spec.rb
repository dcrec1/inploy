require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Inploy::DSL do
  include Inploy::DSL

  it "should recognize a rake task exists even if it has parameters" do
    mute self
    stub_tasks self
    command = "spec param=value"
    expect_command "rake #{command}"
    rake_if_included command
  end
end
