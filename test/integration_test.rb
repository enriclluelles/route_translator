require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require 'route_translator'
require_relative 'dummy/config/environment'

class_to_inherit = defined?(ActionDispatch::IntegrationTest) ? ActionDispatch::IntegrationTest : ActionController::IntegrationTest
class LocaleFromParamsTest < class_to_inherit
  include RouteTranslator::TestHelper

  def test_set_locale_from_params
    config_default_locale_settings 'en'

    get '/es/dummy'
    assert_equal @response.body, 'es'
    assert_response :success
  end
end
