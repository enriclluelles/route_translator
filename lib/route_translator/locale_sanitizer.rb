# frozen_string_literal: true

module RouteTranslator
  module LocaleSanitizer
    module_function

    def sanitize(locale)
      locale.to_s.gsub('native_', '')
    end
  end
end
