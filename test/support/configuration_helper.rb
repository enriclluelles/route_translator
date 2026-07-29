# frozen_string_literal: true

module RouteTranslator
  module ConfigurationHelper
    delegate :reset_config, to: :RouteTranslator

    alias setup_config reset_config
    alias teardown_config reset_config

    def config(**options)
      RouteTranslator.config do |c|
        options.each do |option, value|
          c[option] = value
        end
      end
    end
  end
end
