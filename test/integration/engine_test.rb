# frozen_string_literal: true

require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def test_with_engine_inside_localized_block
    get '/engine_es'
    assert_response :success

    url =
      if Rails.version < '5.1.3'
        '/blorgh/posts'
      else
        '/es/blorgh/posts'
      end

    assert_equal url, response.body
  end

  def test_with_engine_outside_localized_block
    get '/engine'
    assert_response :success
    assert_equal '/blorgh/posts', response.body
  end
end
