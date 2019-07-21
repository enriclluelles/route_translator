# frozen_string_literal: true

module RouteTranslator
  module ConfigurationHelper
    def config_reset
      config_default_locale_settings :en

      RouteTranslator::DEFAULT_CONFIGURATION.each do |option, value|
        RouteTranslator.config[option] = value
      end
    end

    alias setup_config config_reset
    alias teardown_config config_reset

    def config_default_locale_settings(locale = :en)
      I18n.default_locale = locale
    end

    DEFAULT_CONFIGURATION.each do |option, default_value|
      define_method :"config_#{option}" do |value = default_value|
        RouteTranslator.config[option] = value
      end
    end
  end
end
