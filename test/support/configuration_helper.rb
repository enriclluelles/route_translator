# frozen_string_literal: true

module RouteTranslator
  module ConfigurationHelper
    delegate :reset_config, to: :RouteTranslator

    alias setup_config reset_config
    alias teardown_config reset_config

    DEFAULT_CONFIGURATION.each do |option, default_value|
      define_method :"config_#{option}" do |value = default_value|
        RouteTranslator.config[option] = value
      end
    end
  end
end
