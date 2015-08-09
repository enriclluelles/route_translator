require 'action_controller'

module ActionController
  class Base
    around_filter :set_locale_from_url

    def set_locale_from_url
      tmp_default_locale = RouteTranslator::Host.locale_from_host(request.host)
      if tmp_default_locale
        current_default_locale = I18n.default_locale
        I18n.default_locale    = tmp_default_locale
      end
      
      if !session[:redirected_to_accept_language]
        tmp_locale = http_accept_language.compatible_language_from(I18n.available_locales) || tmp_default_locale
        session[:redirected_to_accept_language] = true
        return redirect_to url_for(locale: tmp_locale.to_s)
      end

      tmp_locale = params[RouteTranslator.locale_param_key] || tmp_default_locale
      if tmp_locale
        current_locale = I18n.locale
        I18n.locale    = tmp_locale
      end

      yield

    ensure
      I18n.default_locale = current_default_locale if tmp_default_locale
      I18n.locale = current_locale if tmp_locale
    end
  end
end
