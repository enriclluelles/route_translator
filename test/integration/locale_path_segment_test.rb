# coding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class LocaleSegmentProcTest < integration_test_suite_parent_class
  include RouteTranslator::ConfigurationHelper

  def test_recognize_with_locale_segment_proc
    config_locale_segment_proc ->(locale) { locale.to_s.upcase }
    Rails.application.reload_routes!

    get '/DE-AT/Attrappe' # dummy
    assert_response :success
  end

  def test_recognize_without_locale_segment_proc
    config_locale_segment_proc false
    Rails.application.reload_routes!

    # downcase is default
    get '/de-at/Attrappe' # dummy
    assert_response :success
  end

  def test_generate_with_locale_segment_proc
    config_locale_segment_proc ->(locale) { locale.to_s }
    Rails.application.reload_routes!

    # not the default downcase
    get '/de-AT/anzeigen' # show
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/de-AT/anzeigen' }
  end

  def test_generate_without_locale_segment_proc
    config_locale_segment_proc false
    Rails.application.reload_routes!

    get '/de-at/anzeigen' # show
    assert_response :success
    assert_tag tag: 'a', attributes: { href: '/de-at/anzeigen' }
  end

  # IKEA style "www.ikea.com/gb/en"
  def test_helper_with_locale_segment_proc
    config_locale_segment_proc ->(locale) { locale.to_s.downcase.split('-').reverse.join('/') }
    Rails.application.reload_routes!

    I18n.with_locale(:'de-AT') do
      assert_equal '/at/de/anzeigen', show_path
    end
  end
end
