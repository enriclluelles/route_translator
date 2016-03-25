require 'action_controller'
require 'active_support/concern'

module RouteTranslator
  module Controller
    extend ActiveSupport::Concern

    included do
      around_filter :set_locale_from_url
    end

    private

    def set_locale_from_url
      tmp_default_locale = RouteTranslator::Host.locale_from_host(request.host)
      if tmp_default_locale
        current_default_locale = I18n.default_locale
        I18n.default_locale    = tmp_default_locale
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

  module TestCase
    extend ActiveSupport::Concern
    include ActionController::UrlFor

    included do
      delegate :env, :request, to: :@controller
    end

    def _routes
      @routes
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  ActionController::Base.send :include, RouteTranslator::Controller
  ActionController::TestCase.send :include, RouteTranslator::TestCase
end
