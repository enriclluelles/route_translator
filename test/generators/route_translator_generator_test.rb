# frozen_string_literal: true

require 'test_helper'

require 'rails/generators/test_case'
require 'generators/route_translator/install_generator'

class RouteTranslatorGeneratorTest < Rails::Generators::TestCase
  tests RouteTranslator::Generators::InstallGenerator

  destination File.expand_path('../tmp', __dir__)

  setup :prepare_destination

  teardown { rm_rf(destination_root) }

  def test_generates_the_route_translator_initializer
    run_generator

    configuration_options = RouteTranslator::DEFAULT_CONFIGURATION.map do |option, value|
      Regexp.new(Regexp.escape("# config.#{option} = #{value.inspect}"))
    end

    assert_file 'config/initializers/route_translator.rb', *configuration_options
  end
end
