require 'action_controller'

module ActionController
  class Base
    before_filter :set_default_locale_from_tld, if: -> { RouteTranslator.config.tld_locales[tld] }
    around_filter :set_locale_from_url
    helper_method :locale_from_tld, :tld

    private
    def set_locale_from_url(&block)
      I18n.with_locale(params[RouteTranslator.locale_param_key], &block)
    end

    def set_default_locale_from_tld
      I18n.default_locale = locale_from_tld || I18n.default_locale
      I18n.locale         = locale_from_tld || I18n.locale
    end

    def locale_from_tld
      locale = RouteTranslator.config.tld_locales[tld].try(:to_sym)
      I18n.available_locales.include?(locale) ? locale : nil
    end

    def tld
      tld = request.host.split('.', 2).last.to_sym
    end
  end
end
