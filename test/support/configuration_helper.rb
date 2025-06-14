# frozen_string_literal: true

module RouteTranslator
  module ConfigurationHelper
    delegate :reset_config, to: :RouteTranslator

    alias setup_config reset_config
    alias teardown_config reset_config

    def config(**options)
      options.each do |option, value|
        RouteTranslator.config[option] = value
      end
    end
  end
end
