
module RouteTranslator
  module AssertionHelper

    def assert_helpers_include(*helpers)
      controller = ActionController::Base.new
      view = ActionView::Base.new
      helpers.each do |helper|
        ['url', 'path'].each do |suffix|
          [controller, view].each { |obj| assert_respond_to obj, "#{helper}_#{suffix}".to_sym }
        end
      end
    end

    # Hack for compatibility between Rails 4 and Rails 3
    def assert_unrecognized_route(route_path, options)
      assert_raise ActionController::RoutingError do
        begin
          assert_routing route_path, options
        rescue Minitest::Assertion => m
          raise ActionController::RoutingError.new("")
        end
      end
    end

  end
end
