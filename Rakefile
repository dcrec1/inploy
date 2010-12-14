require 'rubygems'
require 'rubygems/specification'
require 'rake'
require 'rake/gempackagetask'
require 'rspec/core/rake_task'

GEM = "inploy"
GEM_VERSION = "1.8"
SUMMARY = "Rails and Sinatra deployment made easy"
AUTHOR = "Diego Carrion"
EMAIL = "dc.rec1@gmail.com"
HOMEPAGE = "http://www.diegocarrion.com"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = SUMMARY
  s.files = FileList['lib/**/*','bin/*', '[A-Z]*'].to_a
  s.executables << "inploy"

  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE

  s.rubyforge_project = GEM # GitHub bug, gem isn't being build when this miss
end

RSpec::Core::RakeTask.new :spec do |t|
  t.rspec_opts = %w(-fp --color)
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "Create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "Run all examples with RCov"
RSpec::Core::RakeTask.new :spec do |t|
  t.rcov = true
  t.rcov_opts = ['--no-html', '-T', '--exclude', 'spec']
end

desc "Run specs with all the Ruby versions supported"
task :build do
  system "rvm 1.8.7 specs"
  system "rvm 1.9.2 specs"
end
