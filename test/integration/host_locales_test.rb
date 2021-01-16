# frozen_string_literal: true

require 'test_helper'

class HostLocalesTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def setup
    config_host_locales '*.es' => 'es', 'ru.*.com' => 'ru'
    Rails.application.reload_routes!
  end

  def teardown
    teardown_config
    Rails.application.reload_routes!
  end

  def test_root_path
    # root of es com
    host! 'www.testapp.es'
    get '/'
    assert_equal 'es', @response.body
    assert_response :success

    # root of ru com
    host! 'ru.testapp.com'
    get '/'
    assert_equal 'ru', @response.body
    assert_response :success
  end

  def test_explicit_path
    # native es route on es com
    host! 'www.testapp.es'
    get '/dummy'
    assert_equal 'es', @response.body
    assert_response :success

    # native ru route on ru com
    host! 'ru.testapp.com'
    get Addressable::URI.normalize_component('/манекен')
    assert_equal 'ru', @response.body
    assert_response :success
  end

  def test_generated_path
    # native es route on es com
    host! 'www.testapp.es'
    get '/native'
    assert_equal '/mostrar', @response.body
    assert_response :success

    # native ru route on ru com
    host! 'ru.testapp.com'
    get '/native'
    assert_equal Addressable::URI.normalize_component('/показывать'), @response.body
    assert_response :success
  end

  def test_preserve_i18n_locale
    host! 'www.testapp.es'
    get '/native'

    assert_equal :en, I18n.locale
  end

  def test_prefixed_path
    # prefixed es route on es com
    host! 'www.testapp.es'
    get '/es/native'
    assert_response :not_found

    # prefixed ru route on ru com
    host! 'ru.testapp.com'
    get '/ru/native'
    assert_response :not_found
  end

  def test_non_native_path
    # ru route on es com
    host! 'www.testapp.es'
    get Addressable::URI.normalize_component('/ru/манекен')
    assert_response :not_found

    # es route on ru com
    host! 'ru.testapp.com'
    get '/es/dummy'
    assert_response :not_found

    # unprefixed es route on ru com
    host! 'ru.testapp.com'
    get '/dummy'
    assert_response :not_found

    # unprefixed ru route on es com
    host! 'www.testapp.es'
    get Addressable::URI.normalize_component('/манекен')
    assert_response :not_found
  end
end
