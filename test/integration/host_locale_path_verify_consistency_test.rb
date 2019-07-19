# frozen_string_literal: true

require 'test_helper'

class HostLocalePathVerifyConsistencyTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def setup
    config_verify_host_path_consistency true
    config_host_locales '*.es' => 'es', 'ru.*.com' => 'ru'
    Dummy::Application.reload_routes!
  end

  def teardown
    config_verify_host_path_consistency false
    config_host_locales
    Dummy::Application.reload_routes!
  end

  def test_host_path_consistency
    host! 'www.testapp.es'
    get '/dummy'
    assert_response :success

    get Addressable::URI.normalize_component('/манекен')
    assert_response :not_found

    host! 'ru.testapp.com'
    get '/dummy'
    assert_response :not_found

    get Addressable::URI.normalize_component('/манекен')
    assert_response :success
  end
end
