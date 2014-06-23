#encoding: utf-8
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

  def test_i18n_locale_thread_safe
    config_default_locale_settings 'en'

    get '/es/dummy'
    assert_equal 'es', @response.body

    assert_equal :en, I18n.locale
  end

  def test_tld_locales
    # root of es tld
    host! 'testapp.es'
    get '/'
    assert_equal :es, I18n.locale
    assert_equal :es, I18n.default_locale

    # native es route on es tld
    host! 'testapp.es'
    get '/dummy'
    assert_equal 'es', @response.body
    assert_response :success

    # ru route on es tld
    host! 'testapp.es'
    get URI.escape('/ru/манекен')
    assert_equal 'ru', @response.body
    assert_response :success

    # root of ru tld
    host! 'testapp.ru'
    get '/'
    assert_equal :ru, I18n.locale
    assert_equal :ru, I18n.default_locale

    # native ru route on ru tld
    host! 'testapp.ru'
    get URI.escape('/манекен')
    assert_equal 'ru', @response.body
    assert_response :success

    # es route on ru tld
    host! 'testapp.ru'
    get '/es/dummy'
    assert_equal 'es', @response.body
    assert_response :success
  end
end
