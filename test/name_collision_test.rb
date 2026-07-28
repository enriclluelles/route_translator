# frozen_string_literal: true

require 'test_helper'

# When localisation wants to generate a route name that is already taken, the
# localised route must be added *unnamed* and the existing name must keep
# pointing at the route that claimed it first.
#
# This branch had no coverage, which made it easy to change the lookup used by
# `Translator.translate_name` without noticing a behaviour difference.
class NameCollisionTest < ActionController::TestCase
  include ActionDispatch::Assertions::RoutingAssertions
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

  def test_translated_name_is_skipped_when_already_taken
    draw_routes do
      # Claim the name that localising :people would want to generate for :en.
      get 'already', to: 'people#already', as: :people_en

      localized do
        get 'people', to: 'people#index', as: :people
      end
    end

    # The pre-existing route keeps the name...
    assert_equal '/already(.:format)', path_string(named_route('people_en'))

    # ...the other locale is still named normally...
    assert_equal '/gente(.:format)', path_string(named_route('people_es'))

    # ...and the colliding localised route is present but unnamed.
    en_route = @routes.routes.detect do |r|
      r.name.nil? && path_string(r) == '/people(.:format)'
    end

    assert en_route, 'expected the :en localised route to be added without a name'
  end

  def test_route_is_still_reachable_when_its_name_collides
    draw_routes do
      get 'already', to: 'people#already', as: :people_en

      localized do
        get 'people', to: 'people#index', as: :people
      end
    end

    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/gente', controller: 'people', action: 'index', locale: 'es'
  end
end
