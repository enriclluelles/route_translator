# frozen_string_literal: true

require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def test_do_not_raise_invalid_locale_error_for_invalid_locales
    get '/unlocalized?locale=xx'
    assert_response :success
    assert_equal 'en', @response.body
  end

  def test_accepts_valid_locales
    get '/unlocalized?locale=es'
    assert_response :success
    assert_equal 'es', @response.body
  end
end
