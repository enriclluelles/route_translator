# frozen_string_literal: true

require 'test_helper'

class PartialCachingTest < ActionDispatch::IntegrationTest
  def test_supports_partial_caching
    get '/partial_caching'
    assert_response :success
  end
end
