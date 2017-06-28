# frozen_string_literal: true

module RouteTranslator
  module HostPathConsistencyLambdas
    class << self
      private

      def lambdas
        @lambdas ||= {}
      end

      def sanitize_locale(locale)
        locale.to_s.gsub('native_', '')
      end
    end

    module_function

    def for_locale(locale)
      sanitized_locale = sanitize_locale(locale)

      lambdas[sanitized_locale] ||= ->(req) { sanitized_locale == RouteTranslator::Host.locale_from_host(req.host).to_s }
    end
  end
end
