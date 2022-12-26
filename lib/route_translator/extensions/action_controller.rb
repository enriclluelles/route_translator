# frozen_string_literal: true

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
end

ActiveSupport.on_load(:action_controller) { include RouteTranslator::Controller }

ActiveSupport.on_load(:action_controller_test_case) do
  require 'route_translator/extensions/test_case'

  include RouteTranslator::TestCase
end
