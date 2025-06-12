# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'route_translator/version'

Gem::Specification.new do |spec|
  spec.name          = 'route_translator'
  spec.version       = RouteTranslator::VERSION
  spec.authors       = ['Geremia Taglialatela', 'Enric Lluelles', 'Raul Murciano']
  spec.email         = ['tagliala.dev@gmail.com', 'enric@lluell.es']

  spec.summary       = 'Translate your Rails routes in a simple manner'
  spec.description   = 'Translates the Rails routes of your application into the languages defined in your locale files'
  spec.homepage      = 'https://github.com/enriclluelles/route_translator'
  spec.license       = 'MIT'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['bug_tracker_uri'] = 'https://github.com/enriclluelles/route_translator/issues'
  spec.metadata['changelog_uri'] = 'https://github.com/enriclluelles/route_translator/blob/master/CHANGELOG.md'
  spec.metadata['source_code_uri'] = 'https://github.com/enriclluelles/route_translator'

  spec.files         = Dir.glob('{CHANGELOG.md,LICENSE,README.md,lib/**/*.rb}', File::FNM_DOTMATCH)
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1'

  spec.add_dependency 'actionpack', '>= 6.1'
  spec.add_dependency 'activesupport', '>= 6.1'
end
