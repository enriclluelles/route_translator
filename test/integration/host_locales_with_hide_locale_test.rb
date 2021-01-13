# frozen_string_literal: true

require 'test_helper'

class HostLocalesWithHideLocaleTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def setup
    config_verify_host_path_consistency true
    config_hide_locale true
    config_host_locales '*.es' => 'es', '*.co.uk' => 'en'
    Rails.application.reload_routes!
  end

  def teardown
    teardown_config
    Rails.application.reload_routes!
  end

  def test_explicit_path
    # -- testapp.es --
    host! 'testapp.es'

    get '/'
    assert_equal 'es', @response.body
    assert_response :success

    get '/mostrar'
    assert_response :success

    get '/es/mostrar'
    assert_response :not_found

    get '/show'
    assert_response :not_found

    get '/en/show'
    assert_response :not_found

    # -- testapp.co.uk --
    host! 'testapp.co.uk'

    get '/'
    assert_equal 'en', @response.body
    assert_response :success

    get '/show'
    assert_response :success

    get '/en/show'
    assert_response :not_found

    get '/mostrar'
    assert_response :not_found

    get '/es/mostrar'
    assert_response :not_found
  end
end
