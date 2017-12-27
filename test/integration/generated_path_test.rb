# frozen_string_literal: true

require 'test_helper'

class GeneratedPathTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config
  end

  def teardown
    teardown_config
  end

  def test_path_generated
    get '/show'
    assert_response :success
    assert_select 'a[href="/show"]'
  end

  def test_path_translated
    get '/es/mostrar'
    assert_response :success
    assert_select 'a[href="/es/mostrar"]'
  end

  def test_path_translated_after_force
    config_force_locale true

    get '/es/mostrar'
    assert_response :success
    assert_select 'a[href="/es/mostrar"]'
  end

  def test_path_translated_while_generate_unlocalized_routes
    config_default_locale_settings 'en'
    config_generate_unlocalized_routes true

    get '/es/mostrar'
    assert_response :success
    assert_select 'a[href="/es/mostrar"]'
  end

  def test_with_optionals
    get '/optional'
    assert_response :success
    assert_select 'a[href="/optional"]'

    get '/optional/12'
    assert_response :success
    assert_select 'a[href="/optional/12"]'
  end

  def test_with_prefixed_optionals
    get '/prefixed_optional'
    assert_response :success
    assert_select 'a[href="/prefixed_optional"]'

    get '/prefixed_optional/p-12'
    assert_response :success
    assert_select 'a[href="/prefixed_optional/p-12"]'
  end

  def test_with_suffix
    get '/10-suffix'
    assert_response :success
    assert_equal '10', response.body
  end

  def test_path_translated_with_suffix
    get '/es/10-sufijo'
    assert_response :success
    assert_equal '10', response.body
  end

  def test_path_with_slash_in_translation
    get '/es/foo/bar'
    assert_response :success
    assert_equal '/es/foo/bar', response.body
  end
end
