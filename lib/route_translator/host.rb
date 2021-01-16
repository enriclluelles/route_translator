# frozen_string_literal: true

module RouteTranslator
  module Host
    class << self
      private

      def lambdas
        @lambdas ||= {}
      end

      def regex_for(host_string)
        escaped = Regexp.escape(host_string).gsub('\*', '.*?').gsub('\.', '\.?')
        Regexp.new("^#{escaped}$", Regexp::IGNORECASE)
      end
    end

    module_function

    def locale_from_host(host)
      locales = RouteTranslator.config.host_locales.each_with_object([]) do |(pattern, locale), result|
        result << locale.to_sym if host&.match?(regex_for(pattern))
      end
      locales &= I18n.available_locales
      locales.first&.to_sym
    end

    def lambdas_for_locale(locale)
      lambdas[locale] ||= ->(req) { locale == RouteTranslator::Host.locale_from_host(req.host) }
    end
  end
end
