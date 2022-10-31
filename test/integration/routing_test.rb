# frozen_string_literal: true

require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def test_set_locale_from_params_with_around_action
    get '/es/dummy'

    assert_equal 'es', @response.body
    assert_response :success
  end

  def test_does_not_set_locale_from_params_without_around_action
    get '/es/dummy_sin_around_action'

    assert_equal 'en', @response.body
    assert_response :success
  end
end
