# frozen_string_literal: true
require File.expand_path('../../test_helper', __FILE__)

class HelperTestController < ActionController::Base
  def test
    render plain: nil
  end
end

class TestHelperTest < ActionView::TestCase
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config
    config_default_locale_settings 'en'

    @routes = ActionDispatch::Routing::RouteSet.new

    draw_routes do
      localized do
        get :helper_test, to: 'helper_test#test'
      end
    end
  end

  def teardown
    teardown_config
  end

  def test_no_private_method_call
    assert_nothing_raised { helper_test_path }
  end
end
