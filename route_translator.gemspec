# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'route_translator/version'

Gem::Specification.new do |spec|
  spec.name          = 'route_translator'
  spec.version       = RouteTranslator::VERSION
  spec.authors       = ['Raul Murciano', 'Enric Lluelles']
  spec.email         = %q(enric@lluell.es)

  spec.summary       = %q(Translate your Rails routes in a simple manner)
  spec.description   = %q(Translates the Rails routes of your application into the languages defined in your locale files)
  spec.homepage      = %q(http://github.com/enriclluelles/route_translator)
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(gemfiles|test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '>= 3.2', '< 5.0'
  spec.add_runtime_dependency 'actionpack', '>= 3.2', '< 5.0'

  spec.add_development_dependency 'appraisal', '~> 2.1'
  spec.add_development_dependency 'coveralls', '~> 0.8.10'
  spec.add_development_dependency 'minitest', '>= 4.7.5', '< 6.0.0'
  spec.add_development_dependency 'rails', '>= 3.2', '< 5.0'
  spec.add_development_dependency 'rubocop', '~> 0.35'
  spec.add_development_dependency 'simplecov', '~> 0.11.1'
end
