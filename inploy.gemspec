# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{inploy}
  s.version = "1.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Diego Carrion"]
  s.date = %q{2010-04-17}
  s.default_executable = %q{inploy}
  s.email = %q{dc.rec1@gmail.com}
  s.executables = ["inploy"]
  s.files = ["lib/inploy", "lib/inploy/cli.rb", "lib/inploy/deploy.rb", "lib/inploy/dsl.rb", "lib/inploy/helper.rb", "lib/inploy/servers", "lib/inploy/servers/mongrel.rb", "lib/inploy/servers/passenger.rb", "lib/inploy/servers/thin.rb", "lib/inploy/servers/unicorn.rb", "lib/inploy/templates", "lib/inploy/templates/locaweb.rb", "lib/inploy/templates/rails3.rb", "lib/inploy/templates/rails3_push.rb", "lib/inploy.rb", "lib/tasks", "lib/tasks/inploy.rake", "bin/inploy", "Rakefile", "README.textile"]
  s.homepage = %q{http://www.diegocarrion.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{inploy}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Rails deployment made easy}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
