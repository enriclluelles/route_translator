module RouteTranslator
  module Host
    def self.locale_from_host(host)
      matches = RouteTranslator.config.host_locales.detect {|key, locale| host =~ regex_for(key) }
      matched_locale = if matches && host_match = matches.first
                         locale   = RouteTranslator.config.host_locales[host_match].to_sym
                         locale if I18n.available_locales.include?(locale)
                       end
      matched_locale || I18n.default_locale
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

    def locale_param_key
      self.config.locale_param_key
    end
  end
end
