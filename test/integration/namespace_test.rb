# frozen_string_literal: true

require 'test_helper'

class NamespaceTest < ActionDispatch::IntegrationTest
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

  def test_namespacing
    host! 'www.testapp.es'

    get '/cuenta'

    assert_response :success
    assert_equal 'works: es', response.body
  end
end
