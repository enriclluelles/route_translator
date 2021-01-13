# frozen_string_literal: true

module RouteTranslator
  module Host
    class << self
      private

      def regex_for(host_string)
        escaped = Regexp.escape(host_string).gsub('\*', '.*?').gsub('\.', '\.?')
        Regexp.new("^#{escaped}$", Regexp::IGNORECASE)
      end
    end

    def native_locale?(locale)
      locale.to_s.include?('native_')
    end

    def native_locales
      return [] if RouteTranslator.config.hide_locale

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
  end
end
