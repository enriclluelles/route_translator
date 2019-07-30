# frozen_string_literal: true

require 'action_controller'
require 'active_support/concern'

module RouteTranslator
  module Controller
    extend ActiveSupport::Concern

    private

    def set_locale_from_url
      locale_from_url = RouteTranslator.locale_from_params(params) || RouteTranslator::Host.locale_from_host(request.host)
      if locale_from_url
        old_locale  = I18n.locale
        I18n.locale = locale_from_url
      end

      yield
    ensure
      I18n.locale = old_locale if locale_from_url
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
  ActionController::TestCase.send :include, RouteTranslator::TestCase if ENV['RAILS_ENV'] == 'test'
end
