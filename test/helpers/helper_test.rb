# frozen_string_literal: true

require 'test_helper'

class HelperTestController < ApplicationController
  def test
    render plain: nil
  end
end

class TestHelperTest < ActionView::TestCase
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config

    @routes = ActionDispatch::Routing::RouteSet.new

    draw_routes do
      localized do
        get :helper_test, to: 'helper_test#test'
      end
    end
  end

  def teardown
    teardown_config
    Rails.application.reload_routes!
  end

  def test_no_private_method_call
    assert_nothing_raised { helper_test_path }
  end
end
