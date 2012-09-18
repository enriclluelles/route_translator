# encoding: utf-8
require File.expand_path('../lib/route_translator/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "route_translator"
  s.version = RouteTranslator::VERSION

  s.authors = ["Raul Murciano", "Enric Lluelles"]
  s.email = %q{enric@lluell.es}

  s.homepage = %q{http://github.com/enriclluelles/route_translator}

  s.description = %q{Translates the Rails routes of your application into the languages defined in your locale files}
  s.summary = %q{Translate your Rails routes in a simple manner}

  s.files = `git ls-files lib`.split($\)
  s.test_files = `git ls-files test`.split($\)
  s.require_paths = ["lib"]

  s.add_runtime_dependency("mocha")
  s.add_development_dependency("guard-test")
end
