# frozen_string_literal: true

require 'test_helper'

class TestDeprecator < Minitest::Test
  def test_deprecator
    assert_instance_of ActiveSupport::Deprecation, RouteTranslator.deprecator
  end
end
