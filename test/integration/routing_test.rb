# frozen_string_literal: true

require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def test_set_locale_from_params
    get '/es/dummy'
    assert_equal 'es', @response.body
    assert_response :success
  end
end
