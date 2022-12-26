# frozen_string_literal: true

require 'test_helper'

class ThreadSafetyTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def setup
    setup_config
  end

  def teardown
    teardown_config
  end

  def test_i18n_locale_thread_safe
    get '/es/dummy'

    assert_equal 'es', @response.body

    assert_equal :en, I18n.locale
  end
end
