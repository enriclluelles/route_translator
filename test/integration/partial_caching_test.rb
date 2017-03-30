# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class PartialCachingTest < ActionDispatch::IntegrationTest
  def test_supports_partial_caching
    get '/partial_caching'
    assert_response :success
  end
end
