# coding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class RoutingTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def test_set_locale_from_params
    config_default_locale_settings 'en'

    get '/es/dummy'
    assert_equal 'es', @response.body
    assert_response :success
  end

  def test_mounted_apps_work_with_correct_path
    get '/dummy_mounted_app'
    assert_equal 'Good', @response.body
    assert_response :success
  end
end
