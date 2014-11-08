#encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class GeneratedPathTest < integration_test_suite_parent_class

  include RouteTranslator::ConfigurationHelper

  def test_path_generated
    get '/show'
    assert_response :success
    assert_tag :tag => "a", :attributes => { :href => "/show" }
  end

  def test_path_translated
    get '/es/mostrar'
    assert_response :success
    assert_tag :tag => "a", :attributes => { :href => "/es/mostrar" }
  end

  def test_path_translated_after_force
    config_force_locale true

    get '/es/mostrar'
    assert_response :success
    assert_tag :tag => "a", :attributes => { :href => "/es/mostrar" }
  end

  def test_path_translated_while_generate_unlocalized_routes
    config_default_locale_settings 'en'
    config_generate_unlocalized_routes true

    get '/es/mostrar'
    assert_response :success
    assert_tag :tag => "a", :attributes => { :href => "/es/mostrar" }
  end

end
