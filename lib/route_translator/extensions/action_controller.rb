require 'action_controller'

module ActionController
  class Base
    around_filter :set_locale_from_url

    def set_locale_from_url(&block)
      I18n.with_locale params[RouteTranslator.locale_param_key], &block
    end
  end
end
