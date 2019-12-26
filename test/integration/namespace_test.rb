# frozen_string_literal: true

require 'test_helper'

class NamespaceTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def setup
    config_host_locales '*.es' => 'es', 'ru.*.com' => 'ru'
    Rails.application.reload_routes!
  end

  def teardown
    teardown_config
    Rails.application.reload_routes!
  end

  def test_namespacing
    host! 'www.testapp.es'

    get '/cuenta'

    assert_response :success
    assert_equal 'works: es', response.body
  end
end
