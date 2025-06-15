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

    def setup_i18n
      @i18n_available_locales = I18n.available_locales
      @i18n_backend           = I18n.backend
      @i18n_default_locale    = I18n.default_locale
      @i18n_load_path         = I18n.load_path
      @i18n_locale            = I18n.locale
      @i18n_exception_handler = I18n.exception_handler

      I18n.backend   = I18n::Backend::Simple.new
      I18n.load_path = [File.expand_path('../locales/routes.yml', __dir__)]
      I18n.locale    = I18n.default_locale

      I18n.reload!
    end

    def teardown_i18n
      I18n.available_locales = @i18n_available_locales
      I18n.backend           = @i18n_backend
      I18n.default_locale    = @i18n_default_locale
      I18n.load_path         = @i18n_load_path
      I18n.locale            = @i18n_locale
      I18n.exception_handler = @i18n_exception_handler

      I18n.reload!
    end

    def i18n_available_locales(locales)
      I18n.available_locales = locales
      setup_config
    end

    def i18n_default_locale(locale)
      I18n.default_locale = locale
      setup_config
    end
  end
end
