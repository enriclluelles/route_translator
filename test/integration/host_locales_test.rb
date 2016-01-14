# coding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class HostLocalesTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def setup
    config_host_locales '*.es' => 'es', 'ru.*.com' => 'ru'
    Dummy::Application.reload_routes!
  end

  def teardown
    config_host_locales
    Dummy::Application.reload_routes!
  end

  def test_root_path
    ## root of es com
    host! 'www.testapp.es'
    get '/'
    assert_equal 'es', @response.body
    assert_response :success

    ## root of ru com
    host! 'ru.testapp.com'
    get '/'
    assert_equal 'ru', @response.body
    assert_response :success
  end

  def test_explicit_path
    ## native es route on es com
    host! 'www.testapp.es'
    get '/dummy'
    assert_equal 'es', @response.body
    assert_response :success

    ## ru route on es com
    host! 'www.testapp.es'
    get URI.escape('/ru/манекен')
    assert_equal 'ru', @response.body
    assert_response :success

    ## native ru route on ru com
    host! 'ru.testapp.com'
    get URI.escape('/манекен')
    assert_equal 'ru', @response.body
    assert_response :success

    ## es route on ru com
    host! 'ru.testapp.com'
    get '/es/dummy'
    assert_equal 'es', @response.body
    assert_response :success
  end

  def test_generated_path
    ## native es route on es com
    host! 'www.testapp.es'
    get '/native'
    assert_equal '/mostrar', @response.body
    assert_response :success

    ## native ru route on ru com
    host! 'ru.testapp.com'
    get '/native'
    assert_equal URI.escape('/показывать'), @response.body
    assert_response :success
  end
end
