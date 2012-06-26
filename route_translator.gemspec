# encoding: utf-8
require File.expand_path('../lib/route_translator/version', __FILE__)

Gem::Specification.new do |s|
  s.name = %q{translate_routes}
  s.version = RouteTranslator::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Raul Murciano"]
  s.date = %q{2011-04-13}
  s.description = %q{Translates the Rails routes of your application into the languages defined in your locale files}
  s.email = %q{raul@murciano.net}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "lib/route_translator.rb",
    "lib/translate_routes.rb",
    "lib/translate_routes_test_helper.rb"
  ]
  s.homepage = %q{http://github.com/raul/translate_routes}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Translate your Rails routes in a simple manner}
  s.test_files = [
    "test/translate_routes_test.rb"
  ]

  s.add_runtime_dependency 'activesupport'
  s.add_runtime_dependency 'actionpack'
  s.add_runtime_dependency 'journey'

end
