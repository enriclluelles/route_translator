# frozen_string_literal: true

module RouteTranslator
  module ConfigurationHelper
    BOOLEAN_OPTIONS = {
      disable_fallback:                    false,
      force_locale:                        false,
      hide_locale:                         false,
      generate_unlocalized_routes:         false,
      generate_unnamed_unlocalized_routes: false
    }.freeze

    # TODO: FALSE POSITIVE bbatsov/rubocop#5221
    # rubocop:disable Layout/SpaceBeforeBlockBraces
    def config_reset
      config_available_locales            []
      config_default_locale_settings      :en
      config_host_locales                 {}
      config_locale_segment_proc          false
      config_verify_host_path_consistency false

      BOOLEAN_OPTIONS.each do |option, default_value|
        send(:"config_#{option}", default_value)
      end
    end
    # rubocop:enable Layout/SpaceBeforeBlockBraces

    alias setup_config config_reset
    alias teardown_config config_reset

    def config_available_locales(arr)
      RouteTranslator.config.available_locales = arr
    end

    def config_default_locale_settings(locale)
      I18n.default_locale = locale
    end

    def config_host_locales(hash = {})
      RouteTranslator.config.host_locales = hash
    end

    def config_locale_segment_proc(a_proc)
      RouteTranslator.config.locale_segment_proc = a_proc
    end

    def config_verify_host_path_consistency(value)
      RouteTranslator.config.verify_host_path_consistency = value
    end

    BOOLEAN_OPTIONS.each_key do |option|
      define_method :"config_#{option}" do |bool|
        RouteTranslator.config.send(:"#{option}=", bool)
      end
    end
  end
end
