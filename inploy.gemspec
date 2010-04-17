Gem::Specification.new do |gem|
  gem.name    = 'inploy'
  gem.version = '1.99.0'
  gem.date    = Date.today.to_s

  gem.add_dependency 'bundler', '~> 0.9.21'
  # gem.add_dependency 'thor', '~> 0.13.4'
  # gem.add_development_dependency 'rspec', '~> 1.2.9'

  gem.summary = "Rails deployment made easy"
  gem.description = "Inploy is a Rails plugin to deploy applications in a easier way. You can use Inploy from a remote machine or from the local machine, too. It's integrated with Git, Rake and intended to do most of the common work, so you don't need to."

  gem.authors  = ['Diego Carrion', 'Carlos Brando']
  gem.email    = 'dc.rec1@gmail.com'
  gem.homepage = 'http://github.com/dcrec1/inploy/commits/2-0-stable'

  gem.has_rdoc = true
  gem.rdoc_options = ['--main', 'README.rdoc', '--charset=UTF-8']
  gem.extra_rdoc_files = ['README.textile', 'LICENSE', 'CHANGELOG.rdoc']

  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")

  gem.executables << 'deploy'
  gem.default_executable = 'bin/deploy'
end
