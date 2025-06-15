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
      RouteTranslator.config.host_locales.find do |pattern, locale|
        host&.match?(regex_for(pattern)) && RouteTranslator.available_locales.include?(locale&.to_sym)
      end&.last&.to_sym
    end

    def lambdas_for_locale(locale)
      lambdas[locale] ||= ->(req) { locale == RouteTranslator::Host.locale_from_host(req.host) }
    end
  end
end
