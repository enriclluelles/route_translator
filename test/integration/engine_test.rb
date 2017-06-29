# frozen_string_literal: true

require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def test_with_engine_inside_localized_block
    get '/engine_es'
    assert_response :success
    assert_equal '/blorgh/posts', response.body
  end

  def test_with_engine_outside_localized_block
    get '/engine'
    assert_response :success
    assert_equal '/blorgh/posts', response.body
  end
end
