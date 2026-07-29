# frozen_string_literal: true

require 'monitor'

module RouteTranslator
  class AvailableLocales
    MONITOR = Monitor.new

    class << self
      def locales
        cache[:locales]
      end

      def include?(locale)
        cache[:set].include?(locale&.to_sym)
      end

      def clear
        MONITOR.synchronize { @cache = nil }
      end

      private

      def cache
        MONITOR.synchronize do
          @cache ||= begin
            locales = build_locales
            { locales: locales, set: locales.to_set.freeze }
          end
        end
      end

      def build_locales
        locales = configured_locales

        # The default locale must be last so that its routes are drawn after
        # all others. Rails treats later-defined routes as lower priority in
        # wildcard/constraint matching, so placing the default last prevents it
        # from shadowing locale-specific routes.
        default_locale = I18n.default_locale&.to_sym
        locales.delete(default_locale)
        locales.push(default_locale)

        locales.freeze
      end

      def configured_locales
        available_locales = RouteTranslator.config.available_locales.map(&:to_sym)
        i18n_available_locales = I18n.available_locales.map(&:to_sym)
        return i18n_available_locales if available_locales.empty?

        available_locales & i18n_available_locales
      end
    end
  end
end
