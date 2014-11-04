module RouteTranslator
  module Host
    def self.locale_from_host(host)
      locales = RouteTranslator.config.host_locales.reduce([]) do |locales, (pattern, locale)|
        locales << locale.to_sym if host =~ regex_for(pattern)
        locales
      end
      locales &= I18n.available_locales
      (locales.first || I18n.default_locale).to_sym
    end

    def self.regex_for(host_string)
      escaped = Regexp.escape(host_string).gsub('\*', '.*?').gsub('\.', '\.?')
      Regexp.new("^#{escaped}$", Regexp::IGNORECASE)
    end

    def native_locale?(locale)
      !!locale.to_s.match(/native_/)
    end

    def native_locales
      config.host_locales.values.map {|locale| :"native_#{locale}" }
    end
  end
end
