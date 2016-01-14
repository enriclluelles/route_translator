# coding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class GeneratedPathTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def setup
    setup_config
  end

  def teardown
    teardown_config
  end

  def test_path_generated
    get '/show'
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/show' }
  end

  def test_path_translated
    get '/es/mostrar'
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/es/mostrar' }
  end

  def test_path_translated_after_force
    config_force_locale true

    get '/es/mostrar'
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/es/mostrar' }
  end

  def test_path_translated_while_generate_unlocalized_routes
    config_default_locale_settings 'en'
    config_generate_unlocalized_routes true

    get '/es/mostrar'
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/es/mostrar' }
  end

  def test_with_optionals
    get '/optional'
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/optional' }

    get '/optional/12'
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/optional/12' }
  end

  def test_with_prefixed_optionals
    get '/prefixed_optional'
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/prefixed_optional' }

    get '/prefixed_optional/p-12'
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/prefixed_optional/p-12' }
  end

  def test_path_translated_with_suffix
    get '/10-suffix'
    assert_response :success
    assert_equal(response.body, '10')
  end
end
