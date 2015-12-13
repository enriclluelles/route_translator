# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'route_translator/version'

Gem::Specification.new do |s|
  s.name = "route_translator"
  s.version = RouteTranslator::VERSION

  s.authors = ["Raul Murciano", "Enric Lluelles"]
  s.email = %q{enric@lluell.es}

  s.homepage = %q{http://github.com/enriclluelles/route_translator}

  s.description = %q{Translates the Rails routes of your application into the languages defined in your locale files}
  s.summary = %q{Translate your Rails routes in a simple manner}
  s.license = 'MIT'

  s.files = `git ls-files lib`.split($\)
  s.test_files = `git ls-files test`.split($\)
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport', '>= 3.2', '< 5.0'
  s.add_runtime_dependency 'actionpack',    '>= 3.2', '< 5.0'

  s.add_development_dependency 'appraisal', '~> 2.1'
  s.add_development_dependency 'pry', '~> 0.10.3'
end
