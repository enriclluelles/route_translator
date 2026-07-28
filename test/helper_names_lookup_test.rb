# frozen_string_literal: true

require 'test_helper'

# `NamedRouteCollection#helper_names` builds a fresh array of every helper defined
# so far on every call. Calling it while drawing routes makes the cost of drawing
# grow with the size of the route set.
#
# This is deliberately not a timing test. It asserts the shape of the work, which
# is stable on a busy CI machine where wall-clock is not.
class HelperNamesLookupTest < ActionController::TestCase
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::I18nHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config
    setup_i18n
    config hide_locale: true
    @routes = ActionDispatch::Routing::RouteSet.new
  end

  def teardown
    teardown_i18n
    teardown_config
  end

  # Counts around `@routes.draw` rather than the `draw_routes` helper, which also
  # installs the route helpers into ActionController and friends. That is not part
  # of drawing, and counting it would make this assert more than it intends.
  def test_does_not_build_the_helper_name_list_while_drawing_routes
    calls = count_calls_to(ActionDispatch::Routing::RouteSet::NamedRouteCollection, :helper_names) do
      @routes.draw do
        localized do
          20.times { |i| get "segment#{i}", to: 'people#index', as: :"thing#{i}" }
        end
      end
    end

    assert_equal 0, calls, "expected no calls to NamedRouteCollection#helper_names, got #{calls}"
  end

  # The push that used to happen here never took effect, so removing it must leave
  # the collection's view of its helpers exactly as it was.
  def test_helper_names_still_reports_the_routes_rails_registered
    draw_routes do
      localized do
        get 'people', to: 'people#index', as: :people
      end
    end

    helper_names = @routes.named_routes.helper_names

    assert_includes helper_names, 'people_en_path'
    assert_includes helper_names, 'people_es_url'
  end

  private

  def count_calls_to(klass, method)
    count = 0
    original = klass.instance_method(method)

    klass.define_method(method) do |*args, &blk|
      count += 1
      original.bind_call(self, *args, &blk)
    end

    yield
    count
  ensure
    klass.define_method(method, original)
  end
end
