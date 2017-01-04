module RouteTranslator
  module ConfigurationHelper
    def config_reset
      config_force_locale false
      config_hide_locale false
      config_generate_unlocalized_routes false
      config_generate_unnamed_unlocalized_routes false
      config_host_locales {}
      config_available_locales []
      config_disable_fallback false
      config_locale_segment_proc false

      config_default_locale_settings :en
    end

    alias setup_config config_reset
    alias teardown_config config_reset

    def config_default_locale_settings(locale)
      I18n.default_locale = locale
    end

    def config_force_locale(boolean)
      RouteTranslator.config.force_locale = boolean
    end

    def config_hide_locale(boolean)
      RouteTranslator.config.hide_locale = boolean
    end

    def config_generate_unlocalized_routes(boolean)
      RouteTranslator.config.generate_unlocalized_routes = boolean
    end

    def config_generate_unnamed_unlocalized_routes(boolean)
      RouteTranslator.config.generate_unnamed_unlocalized_routes = boolean
    end

    def config_host_locales(hash = {})
      RouteTranslator.config.host_locales = hash
    end

    def config_available_locales(arr)
      RouteTranslator.config.available_locales = arr
    end

    def config_disable_fallback(boolean)
      RouteTranslator.config.disable_fallback = boolean
    end

    def config_locale_segment_proc(a_proc)
      RouteTranslator.config.locale_segment_proc = a_proc
    end
  end
end
