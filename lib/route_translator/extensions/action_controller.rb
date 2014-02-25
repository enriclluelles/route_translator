require 'action_controller'

module ActionController
  class Base
    before_filter :set_locale_from_url

    def set_locale_from_url
      I18n.locale = params[RouteTranslator.locale_param_key]
    end
  end

  class TestCase
  	include ActionController::UrlFor

  	delegate :env, :request, :to => :@controller
  	def _routes; @routes; end
  end
end
