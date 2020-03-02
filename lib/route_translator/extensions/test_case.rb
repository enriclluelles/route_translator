# frozen_string_literal: true

require 'action_controller'

module RouteTranslator
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
