module RouteTranslator
  module RouteSet
    module Helpers
      def available_locales
        @available_locales ||= I18n.available_locales.map(&:to_s)
      end

      def available_locales= locales
        @available_locales = locales.map(&:to_s)
      end

      def default_locale
        @default_locale ||= I18n.default_locale.to_s
      end

      def default_locale= locale
        @default_locale = locale.to_s
      end

      def default_locale? locale
        default_locale == locale.to_s
      end

      def locale_suffix locale
        RouteTranslator.locale_suffix locale
      end
    end
  end
end
