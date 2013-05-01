require 'action_controller'

module ActionController
  class Base
    def set_locale_from_url
      I18n.locale = params[RouteTranslator.locale_param_key]
    end
  end
end
