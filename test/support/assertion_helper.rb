# frozen_string_literal: true

module RouteTranslator
  module AssertionHelper
    SUFFIXES = %w[url path].freeze

    def assert_helpers_include(*helpers)
      controller = ActionController::Base.new
      view = ActionView::Base.new(nil, {}, nil)
      helpers.each do |helper|
        SUFFIXES.each do |suffix|
          [controller, view].each { |obj| assert_respond_to obj, "#{helper}_#{suffix}".to_sym }
        end
      end
    end

    def assert_unrecognized_route(route_path, options)
      assert_raise Minitest::Assertion do
        assert_routing route_path, options
      end
    end
  end
end
