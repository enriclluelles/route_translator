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

    def native_locale?(locale)
      locale.to_s.include?('native_')
    end

    def native_locales
      config.host_locales.values.map { |locale| :"native_#{locale}" }
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
      sanitized_locale = RouteTranslator::LocaleSanitizer.sanitize(locale)

      lambdas[sanitized_locale] ||= ->(req) { sanitized_locale == RouteTranslator::Host.locale_from_host(req.host).to_s }
    end
  end
end
