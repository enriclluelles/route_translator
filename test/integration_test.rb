require File.expand_path('../test_helper', __FILE__)
require 'route_translator'
require File.expand_path('../dummy/dummy_mounted_app', __FILE__)
require File.expand_path('../dummy/config/environment', __FILE__)

class_to_inherit = defined?(ActionDispatch::IntegrationTest) ? ActionDispatch::IntegrationTest : ActionController::IntegrationTest
class IntegrationTest < class_to_inherit
  include RouteTranslator::TestHelper

  def test_set_locale_from_params
    config_default_locale_settings 'en'

    get '/es/dummy'
    assert_equal 'es', @response.body
    assert_response :success
  end

  def test_mounted_apps_work_with_correct_path
    get 'dummy_mounted_app'
    assert_equal "Good", @response.body
    assert_response :success
  end
end
