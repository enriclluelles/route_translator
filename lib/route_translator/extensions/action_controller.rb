require 'action_controller'

module ActionController
  class Base
    around_filter :set_locale_from_url

    def set_locale_from_url(&block)
      with_host_locale { I18n.with_locale(params[RouteTranslator.locale_param_key], &block) }
    end

    private

    def with_host_locale(&block)
      host_locale = RouteTranslator::Host.locale_from_host(request.host)
      begin
        if host_locale
          original_default         = I18n.default_locale
          original_locale          = I18n.locale

          I18n.default_locale = host_locale
          I18n.locale         = host_locale
        end

        yield

      ensure
        I18n.default_locale = original_default if host_locale
        I18n.locale         = original_locale  if host_locale
      end
    end
    
  end
end
