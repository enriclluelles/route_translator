# frozen_string_literal: true

require 'test_helper'

class PeopleController < ApplicationController
end

class ProductsController < ApplicationController
end

module People
  class ProductsController < ApplicationController
  end
end

class TranslateRoutesTest < ActionController::TestCase
  include ActionDispatch::Assertions::RoutingAssertions
  include RouteTranslator::AssertionHelper
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::I18nHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config
    setup_i18n
    @routes = ActionDispatch::Routing::RouteSet.new
  end

  def teardown
    teardown_i18n
    teardown_config
  end

  def test_unnamed_root_route
    draw_routes do
      localized do
        root to: 'people#index'
      end
    end

    assert_routing '/', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/es', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/de-at', controller: 'people', action: 'index', locale: 'de-AT'
  end

  def test_params
    draw_routes do
      localized do
        resources :products
      end
    end

    assert_routing '/es/productos/product_slug', controller: 'products', action: 'show', locale: 'es', id: 'product_slug'
  end

  def test_slash_in_translation
    draw_routes do
      localized do
        get 'slash', to: 'products#index'
      end
    end

    assert_routing '/es/foo/bar', controller: 'products', action: 'index', locale: 'es'
  end

  def test_optional_segments
    draw_routes do
      localized do
        get 'products(/:optional_param)/:non_optional_param', to: 'products#index'
      end
    end

    assert_routing '/es/productos/a', controller: 'products', action: 'index', locale: 'es', non_optional_param: 'a'
    assert_routing '/es/productos/a/b', controller: 'products', action: 'index', locale: 'es', non_optional_param: 'b', optional_param: 'a'
  end

  def test_translations_after_optional_segments
    draw_routes do
      localized do
        get '(/:optional_param)/products', to: 'products#index'
      end
    end

    assert_routing '/es/productos', controller: 'products', action: 'index', locale: 'es'
    assert_routing '/es/a/productos', controller: 'products', action: 'index', locale: 'es', optional_param: 'a'
  end

  def test_dynamic_segments_dont_get_translated
    draw_routes do
      localized do
        get 'products/:tr_param', to: 'products#index', constraints: { tr_param: /\w/ }
      end
    end
    assert_routing '/es/productos/a', controller: 'products', action: 'index', locale: 'es', tr_param: 'a'
  end

  def test_block_constraints_dont_fail
    assert_nothing_raised do
      draw_routes do
        localized do
          get 'products/:tr_param', to: 'products#index', constraints: -> { true }
        end
      end
    end
  end

  def test_block_constraints_remain_obeyed
    draw_routes do
      localized do
        get 'products', to: 'zambonis#index', constraints: ->(_req) { false }
        get 'products', to: 'products#index', constraints: ->(_req) { true }
      end
    end

    assert_routing '/products', controller: 'products', action: 'index', locale: 'en'
  end

  def test_wildcards_dont_get_translated
    draw_routes do
      localized do
        get 'products/*tr_param', to: 'products#index'
      end
    end
    assert_routing '/es/productos/a/b', controller: 'products', action: 'index', locale: 'es', tr_param: 'a/b'
  end

  def test_resources
    I18n.default_locale = :es

    draw_routes do
      localized do
        resources :products
      end
    end

    assert_routing '/en/products', controller: 'products', action: 'index', locale: 'en'
    assert_routing '/productos', controller: 'products', action: 'index', locale: 'es'
    assert_routing({ path: '/productos/1', method: 'GET' }, controller: 'products', action: 'show', id: '1', locale: 'es')
    assert_routing({ path: '/productos/1', method: 'PUT' }, controller: 'products', action: 'update', id: '1', locale: 'es')
  end

  def test_utf8_characters
    draw_routes do
      localized do
        get 'people', to: 'people#index'
      end
    end

    assert_routing Addressable::URI.normalize_component('/ru/люди'), controller: 'people', action: 'index', locale: 'ru'
  end

  def test_resources_with_only
    I18n.default_locale = :es

    draw_routes do
      localized do
        resources :products, only: %i[index show]
      end
    end

    assert_routing '/en/products', controller: 'products', action: 'index', locale: 'en'
    assert_routing '/productos', controller: 'products', action: 'index', locale: 'es'
    assert_routing({ path: '/productos/1', method: 'GET' }, controller: 'products', action: 'show', id: '1', locale: 'es')
    assert_unrecognized_route({ path: '/productos/1', method: 'PUT' }, controller: 'products', action: 'update', id: '1', locale: 'es')
  end

  def test_namespaced_controllers
    I18n.default_locale = :es

    draw_routes do
      localized do
        get 'people/favourites', to: 'people/products#favourites'
        get 'favourites',        to: 'products#favourites'
      end
    end

    assert_routing '/gente/fans', controller: 'people/products', action: 'favourites', locale: 'es'
    assert_routing '/favoritos', controller: 'products', action: 'favourites', locale: 'es'
    assert_routing Addressable::URI.normalize_component('/ru/люди/кандидаты'), controller: 'people/products', action: 'favourites', locale: 'ru'
    assert_routing Addressable::URI.normalize_component('/ru/избранное'), controller: 'products', action: 'favourites', locale: 'ru'
  end

  def test_unnamed_root_route_without_prefix
    I18n.default_locale = :es

    draw_routes do
      localized do
        root to: 'people#index'
      end
    end

    assert_routing '/', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/en', controller: 'people', action: 'index', locale: 'en'
    assert_unrecognized_route '/es', controller: 'people', action: 'index', locale: 'es'
  end

  def test_unnamed_untranslated_route
    draw_routes do
      localized do
        get 'foo', to: 'people#index'
      end
    end

    assert_routing '/es/foo', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/foo', controller: 'people', action: 'index', locale: 'en'
  end

  def test_explicitly_unnamed_untranslated_route
    draw_routes do
      localized do
        get 'foo', to: 'people#index', as: nil
      end
    end

    assert_routing '/foo', controller: 'people', action: 'index', locale: 'en'
  end

  def test_unnamed_translated_route_on_default_locale
    I18n.default_locale = :es

    @routes.draw { get 'people', to: 'people#index' }
    draw_routes do
      localized do
        get 'people', to: 'people#index'
      end
    end

    assert_routing '/en/people', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/gente', controller: 'people', action: 'index', locale: 'es'
  end

  def test_unnamed_translated_route_on_non_default_locale
    draw_routes do
      localized do
        get 'people', to: 'people#index'
      end
    end

    assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'
  end

  def test_named_translated_route_with_prefix_must_have_locale_as_static_segment
    draw_routes do
      localized do
        get 'people', to: 'people#index'
      end
    end

    # we check the string representation of the route,
    # if it stores locale as a dynamic segment it would be represented as: "/:locale/gente"
    assert_equal '/es/gente(.:format)', path_string(named_route('people_es'))
  end

  def test_named_empty_route_without_prefix
    I18n.default_locale = :es

    draw_routes do
      localized do
        root to: 'people#index', as: 'people'
      end
    end

    assert_routing '/en', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/', controller: 'people', action: 'index', locale: 'es'
    assert_routing '', controller: 'people', action: 'index', locale: 'es'
  end

  def test_named_root_route_without_prefix
    I18n.default_locale = :es

    draw_routes do
      localized do
        root to: 'people#index'
      end
    end

    assert_routing '/', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/en', controller: 'people', action: 'index', locale: 'en'
    assert_unrecognized_route '/es', controller: 'people', action: 'index', locale: 'es'
  end

  def test_named_untranslated_route_without_prefix
    I18n.default_locale = :es

    draw_routes do
      localized do
        get 'foo', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/en/foo', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/foo', controller: 'people', action: 'index', locale: 'es'

    assert_helpers_include :people_en, :people_es, :people
  end

  def test_named_translated_route_on_default_locale_without_prefix
    I18n.default_locale = :es

    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/en/people', controller: 'people', action: 'index', locale: 'en'
    assert_routing 'gente', controller: 'people', action: 'index', locale: 'es'

    assert_helpers_include :people_en, :people_es, :people
  end

  def test_named_translated_route_on_non_default_locale_without_prefix
    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'

    assert_helpers_include :people_en, :people_es, :people
  end

  def test_formatted_root_route
    draw_routes do
      localized do
        root to: 'people#index', as: 'root'
      end
    end

    assert_equal '/', path_string(named_route('root_en'))
    assert_equal '/es', path_string(named_route('root_es'))
  end

  def test_route_with_mandatory_format
    draw_routes do
      localized do
        get 'people.:format', to: 'people#index'
      end
    end

    assert_routing '/es/gente.xml', controller: 'people', action: 'index', format: 'xml', locale: 'es'
    assert_routing '/people.xml', controller: 'people', action: 'index', format: 'xml', locale: 'en'
  end

  def test_route_with_optional_format
    draw_routes do
      localized do
        get 'people(.:format)', to: 'people#index'
      end
    end

    assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/es/gente.xml', controller: 'people', action: 'index', format: 'xml', locale: 'es'
    assert_routing '/people.xml', controller: 'people', action: 'index', format: 'xml', locale: 'en'
  end

  def test_routes_with_dot
    draw_routes do
      localized do
        get 'people/.:name', to: 'people#index'
        get 'products.:name', to: 'products#index'
      end
    end

    assert_routing '/people/.john', controller: 'people', action: 'index', locale: 'en', name: 'john'
    assert_routing '/products.book', controller: 'products', action: 'index', locale: 'en', name: 'book'
  end

  def test_i18n_based_translations_setting_locales
    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'

    assert_helpers_include :people_en, :people_es, :people
  end

  def test_translations_depend_on_available_locales
    I18n.available_locales = %i[es en fr]

    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/fr/people', controller: 'people', action: 'index', locale: 'fr'
    assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'

    assert_helpers_include :people_fr, :people_en, :people_es, :people
  end

  def test_2_localized_blocks
    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
      localized do
        get 'products', to: 'products#index', as: 'products'
      end
    end

    assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/es/productos', controller: 'products', action: 'index', locale: 'es'
  end

  def test_not_localizing_routes_outside_blocks
    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
      get 'products', to: 'products#index', as: 'products'
    end

    assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/products', controller: 'products', action: 'index'
    assert_unrecognized_route '/es/productos', controller: 'products', action: 'index', locale: 'es'
  end

  def test_force_locale
    config_force_locale true

    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/en/people', controller: 'people', action: 'index', locale: 'en'
    assert_unrecognized_route '/people', controller: 'people', action: 'index'
    assert_equal '/en/people', @routes.url_helpers.people_en_path
    assert_equal '/en/people', @routes.url_helpers.people_path
    I18n.with_locale :es do
      # The dynamic route maps to the current locale
      assert_equal '/es/gente', @routes.url_helpers.people_path
    end
  end

  def test_generate_unlocalized_routes
    config_generate_unlocalized_routes true

    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/en/people', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/people', controller: 'people', action: 'index'
    assert_equal '/en/people', @routes.url_helpers.people_en_path
    assert_equal '/people', @routes.url_helpers.people_path

    I18n.with_locale :es do
      # The dynamic route maps to the default locale, not the current
      assert_equal '/people', @routes.url_helpers.people_path
    end
  end

  def test_generate_unnamed_unlocalized_routes
    config_generate_unnamed_unlocalized_routes true

    draw_routes do
      localized do
        get 'people', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/en/people', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/people', controller: 'people', action: 'index'
    assert_equal '/en/people', @routes.url_helpers.people_en_path
    assert_equal '/en/people', @routes.url_helpers.people_path

    I18n.with_locale :es do
      # The dynamic route maps to the current locale
      assert_equal '/es/gente', @routes.url_helpers.people_path
    end
  end

  def test_blank_localized_routes
    draw_routes do
      localized do
        get 'people/blank', to: 'people#index', as: 'people'
      end
    end

    I18n.with_locale :en do
      assert_routing '/people/blank', controller: 'people', action: 'index', locale: 'en'
      assert_equal '/people/blank', @routes.url_helpers.people_en_path
    end

    I18n.with_locale :es do
      assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'
      assert_equal '/es/gente', @routes.url_helpers.people_es_path
    end
  end

  def test_path_helper_arguments_with_host_locales
    I18n.default_locale = :es
    config_host_locales '*.es' => 'es', '*.com' => 'en'

    draw_routes do
      localized do
        resources :products
      end
    end

    I18n.with_locale :es do
      assert_equal '/productos',                           @routes.url_helpers.products_path
      assert_equal '/productos/some_product',              @routes.url_helpers.product_path('some_product')
      assert_equal '/productos/some_product?some=param',   @routes.url_helpers.product_path('some_product', some: 'param')
    end
  end

  def test_path_helper_arguments_fallback
    I18n.available_locales = %i[es en it]
    I18n.default_locale = :it
    config_available_locales %i[en]

    draw_routes do
      localized do
        resources :products
      end
    end

    I18n.with_locale :es do
      assert_equal '/products/some_product?some=param', @routes.url_helpers.product_path('some_product', some: 'param', locale: 'it')
    end
  end

  def test_dont_add_locale_to_routes_if_local_param_present
    I18n.default_locale = :es
    config_force_locale true

    draw_routes do
      scope 'segment/:locale' do
        localized do
          resources :products, only: :show
        end
      end
    end

    assert_routing '/segment/es/productos/product_slug', controller: 'products', action: 'show', locale: 'es', id: 'product_slug'
    assert_routing '/segment/en/products/product_slug', controller: 'products', action: 'show', locale: 'en', id: 'product_slug'
  end

  def test_config_hide_locale
    config_hide_locale true

    draw_routes do
      localized do
        resources :people
      end
    end

    assert_routing '/gente', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'
  end

  def test_host_locales
    config_host_locales '*.es' => 'es', '*.com' => 'en'

    draw_routes do
      localized do
        resources :people
      end
      root to: 'people#index'
    end

    assert_recognizes({ controller: 'people', action: 'index', locale: 'es' }, path: 'http://testapp.es/gente',    method: :get)
    assert_recognizes({ controller: 'people', action: 'index' },               path: 'http://testapp.es/',         method: :get)

    assert_recognizes({ controller: 'people', action: 'index', locale: 'en' }, path: 'http://testapp.com/people',  method: :get)
    assert_recognizes({ controller: 'people', action: 'index' },               path: 'http://testapp.com/',        method: :get)
  end

  def test_action_controller_gets_locale_setter
    ActionController::Base.instance_methods.include?('set_locale_from_url')
  end

  def test_action_controller_gets_locale_suffix_helper
    ActionController::Base.instance_methods.include?('locale_suffix')
  end

  def test_action_view_gets_locale_suffix_helper
    ActionView::Base.instance_methods.include?('locale_suffix')
  end

  # See https://github.com/enriclluelles/route_translator/issues/69
  def test_no_side_effects
    draw_routes do
      localized do
        resources :people
      end

      scope '(:locale)', locale: /(en|es)/ do
        get '*id' => 'products#show', as: 'product'
      end
    end

    assert_routing '/es/gente', controller: 'people', action: 'index', locale: 'es'
    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'

    assert_routing '/es/path/to/a/product', controller: 'products', action: 'show', locale: 'es', id: 'path/to/a/product'
    assert_routing '/path/to/another/product', controller: 'products', action: 'show', id: 'path/to/another/product'
  end

  def test_config_available_locales
    config_available_locales %i[en ru]

    draw_routes do
      localized do
        resources :people
      end
    end

    assert_routing Addressable::URI.normalize_component('/ru/люди'), controller: 'people', action: 'index', locale: 'ru'
    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'
    assert_unrecognized_route '/es/gente', controller: 'people', action: 'index', locale: 'es'
  end

  def test_config_available_locales_handles_strings
    config_available_locales %w[en ru]

    draw_routes do
      localized do
        resources :people
      end
    end

    assert_routing Addressable::URI.normalize_component('/ru/люди'), controller: 'people', action: 'index', locale: 'ru'
    assert_routing '/people', controller: 'people', action: 'index', locale: 'en'
    assert_unrecognized_route '/es/gente', controller: 'people', action: 'index', locale: 'es'
  end

  def test_disable_fallback_does_not_draw_non_default_routes
    config_disable_fallback(true)

    draw_routes do
      localized do
        get 'tr_param', to: 'people#index', as: 'people'
      end
    end

    assert_routing '/tr_param', controller: 'people', action: 'index', locale: 'en'
    assert_routing '/es/tr_parametro', controller: 'people', action: 'index', locale: 'es'
    assert_unrecognized_route '/ru/tr_param', controller: 'people', action: 'index', locale: 'ru'
  end

  def test_disable_fallback_does_not_raise_error
    I18n.exception_handler = ->(*_args) { raise I18n::MissingTranslationData.new('test', 'raise') }
    config_disable_fallback(true)

    draw_routes do
      localized do
        get 'tr_param', to: 'people#index', as: 'people'
      end
    end

    assert_unrecognized_route '/ru/tr_param', controller: 'people', action: 'index', locale: 'ru'
  end
end

class ProductsControllerTest < ActionController::TestCase
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::I18nHelper
  include ActionDispatch::Assertions::RoutingAssertions
  include RouteTranslator::RoutesHelper

  def setup
    setup_config
    setup_i18n

    @routes = ActionDispatch::Routing::RouteSet.new

    I18n.default_locale = :es
    config_host_locales es: 'es'

    draw_routes do
      localized do
        resources :products
      end
    end
  end

  def teardown
    teardown_i18n
    teardown_config
  end

  def test_url_helpers_are_included
    controller = ProductsController.new

    %i[product_path product_url product_es_path product_es_url].each do |method_name|
      assert_respond_to controller, method_name
    end
  end
end
