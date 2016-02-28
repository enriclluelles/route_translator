# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'route_translator/version'

Gem::Specification.new do |spec|
  spec.name          = 'route_translator'
  spec.version       = RouteTranslator::VERSION
  spec.authors       = ['Geremia Taglialatela', 'Enric Lluelles', 'Raul Murciano']
  spec.email         = %q(tagliala.dev@gmail.com enric@lluell.es)

  spec.summary       = %q(Translate your Rails routes in a simple manner)
  spec.description   = %q(Translates the Rails routes of your application into the languages defined in your locale files)
  spec.homepage      = %q(http://github.com/enriclluelles/route_translator)
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z -- {CHANGELOG.md,LICENSE,README.md,lib}`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 3.2', '< 5.0'
  spec.add_runtime_dependency 'actionpack', '>= 3.2', '< 5.0'

  spec.add_development_dependency 'appraisal', '~> 2.1'
  spec.add_development_dependency 'coveralls', '~> 0.8.10'
  spec.add_development_dependency 'minitest', '>= 4.7.5', '< 6.0.0'
  spec.add_development_dependency 'rails', '>= 3.2', '< 5.0'
  spec.add_development_dependency 'rubocop', '~> 0.37.2'
  spec.add_development_dependency 'simplecov', '~> 0.11.2'
end
