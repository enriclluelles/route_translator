#encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require 'route_translator'

class PeopleController < ActionController::Base;  end
class ProductsController < ActionController::Base;  end

class TranslateRoutesTest < ActionController::TestCase
  include ActionDispatch::Assertions::RoutingAssertions
  include RouteTranslator::TestHelper

  def setup
    @routes = ActionDispatch::Routing::RouteSet.new
    I18n.backend = I18n::Backend::Simple.new
    I18n.load_path = [ File.expand_path('../locales/routes.yml', __FILE__) ]
    I18n.reload!
  end

  def teardown
    config_force_locale false
    config_generate_unlocalized_routes false
    config_default_locale_settings("en")
  end

  def test_unnamed_root_route
    config_default_locale_settings 'en'
    draw_routes do
      localized do
        root :to => 'people#index'
      end
    end

    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_params
    draw_routes do
      localized do
        resources :products
      end
    end

    assert_routing '/es/productos/product_slug', :controller => 'products', :action => 'show', :locale => 'es', :id => 'product_slug'
  end

  def test_optional_segments
    draw_routes do
      localized do
        get 'products(/:optional_param)/:non_optional_param', :to => 'products#index'
      end
    end

    assert_routing '/es/productos/a', :controller => 'products', :action => 'index', :locale => 'es', :non_optional_param => 'a'
    assert_routing '/es/productos/a/b', :controller => 'products', :action => 'index', :locale => 'es', :non_optional_param => 'b', :optional_param => 'a'
  end

  def test_dynamic_segments_dont_get_translated
    draw_routes do
      localized do
        get 'products/:tr_param', :to => 'products#index', :constraints => { :tr_param => /\w/ }
      end
    end
    assert_routing '/es/productos/a', :controller => 'products', :action => 'index', :locale => 'es', :tr_param => 'a'
  end

  def test_wildcards_dont_get_translated
    draw_routes do
      localized do
        get 'products/*tr_param', :to => 'products#index', :constraints => { :tr_param => /\w/ }
      end
    end
    assert_routing '/es/productos/a/b', :controller => 'products', :action => 'index', :locale => 'es', :tr_param => 'a/b'
  end

  def test_resources
    config_default_locale_settings 'es'

    draw_routes do
      localized do
        resources :products
      end
    end


    assert_routing '/en/products', :controller => 'products', :action => 'index', :locale => 'en'
    assert_routing '/productos', :controller => 'products', :action => 'index', :locale => 'es'
    assert_routing({:path => '/productos/1', :method => "GET"}, {:controller => 'products', :action => 'show', :id => '1', :locale => 'es'})
    assert_routing({:path => '/productos/1', :method => "PUT"}, {:controller => 'products', :action => 'update', :id => '1', :locale => 'es'})
  end

  def test_utf8_characters
    draw_routes do
      localized do
        get 'people', :to => 'people#index'
      end
    end

    assert_routing URI.escape('/ru/люди'), :controller => 'people', :action => 'index', :locale => 'ru'
  end

  def test_resources_with_only
    config_default_locale_settings 'es'

    draw_routes do
      localized do
        resources :products, :only => [:index, :show]
      end
    end

    assert_routing '/en/products', :controller => 'products', :action => 'index', :locale => 'en'
    assert_routing '/productos', :controller => 'products', :action => 'index', :locale => 'es'
    assert_routing({:path => '/productos/1', :method => "GET"}, {:controller => 'products', :action => 'show', :id => '1', :locale => 'es'})
    assert_unrecognized_route({:path => '/productos/1', :method => "PUT"}, {:controller => 'products', :action => 'update', :id => '1', :locale => 'es'})
  end

  def test_unnamed_root_route_without_prefix
    config_default_locale_settings 'es'

    draw_routes do
      localized do
        root :to => 'people#index'
      end
    end

    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_unnamed_untranslated_route
    config_default_locale_settings 'en'

    draw_routes do
      localized do
        get 'foo', :to => 'people#index'
      end
    end

    assert_routing '/es/foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/foo', :controller => 'people', :action => 'index', :locale => 'en'
  end

  def test_unnamed_translated_route_on_default_locale
    config_default_locale_settings 'es'

    @routes.draw { get 'people', :to => 'people#index' }
    draw_routes do
      localized do
        get 'people', :to => 'people#index'
      end
    end


    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/gente', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_unnamed_translated_route_on_non_default_locale
    config_default_locale_settings 'en'
    draw_routes do
      localized do
        get 'people', :to => 'people#index'
      end
    end

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
  end

  def test_named_translated_route_with_prefix_must_have_locale_as_static_segment
    config_default_locale_settings 'en'

    draw_routes do
      localized do
        get 'people', :to => 'people#index'
      end
    end

    # we check the string representation of the route,
    # if it stores locale as a dynamic segment it would be represented as: "/:locale/gente"
    assert_equal "/es/gente(.:format)", path_string(named_route('people_es'))
  end

  def test_named_empty_route_without_prefix
    config_default_locale_settings 'es'
    draw_routes do
      localized do
        root :to => 'people#index', :as => 'people'
      end
    end

    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_named_root_route_without_prefix
    config_default_locale_settings 'es'

    draw_routes do
      localized do
        root :to => 'people#index'
      end
    end

    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_named_untranslated_route_without_prefix
    config_default_locale_settings 'es'

    draw_routes do
      localized do
        get 'foo', :to => 'people#index', :as => 'people'
      end
    end

    assert_routing '/en/foo', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/foo', :controller => 'people', :action => 'index', :locale => 'es'

    assert_helpers_include :people_en, :people_es, :people
  end

  def test_named_translated_route_on_default_locale_without_prefix
    config_default_locale_settings 'es'

    draw_routes do
      localized do
        get 'people', :to => 'people#index', :as => 'people'
      end
    end

    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing 'gente', :controller => 'people', :action => 'index', :locale => 'es'

    
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_named_translated_route_on_non_default_locale_without_prefix
    draw_routes do
      localized do
        get 'people', :to => 'people#index', :as => 'people'
      end
    end

    config_default_locale_settings 'en'

    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'

    
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_formatted_root_route
    draw_routes do
      localized do
        root :to => 'people#index', :as => 'root'
      end
    end

    if formatted_root_route?
      assert_equal '/(.:format)', path_string(named_route('root_en'))
      assert_equal '/es(.:format)', path_string(named_route('root_es'))
    else
      assert_equal '/', path_string(named_route('root_en'))
      assert_equal '/es', path_string(named_route('root_es'))
    end
  end

  def test_i18n_based_translations_setting_locales
    config_default_locale_settings 'en'

    draw_routes do
      localized do
        get 'people', :to => 'people#index', :as => 'people'
      end
    end

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'

    
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_translations_depend_on_available_locales
    config_default_locale_settings 'en'

    I18n.stub(:available_locales, [:es, :en, :fr]) do
      draw_routes do
        localized do
          get 'people', :to => 'people#index', :as => 'people'
        end
      end
    end

    assert_routing '/fr/people', :controller => 'people', :action => 'index', :locale => 'fr'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'

    assert_helpers_include :people_fr, :people_en, :people_es, :people
  end

  def test_2_localized_blocks
    draw_routes do
      localized do
        get 'people', :to => 'people#index', :as => 'people'
      end
      localized do
        get 'products', :to => 'products#index', :as => 'products'
      end
    end

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/es/productos', :controller => 'products', :action => 'index', :locale => 'es'
  end

  def test_not_localizing_routes_outside_blocks
    config_default_locale_settings 'en'
    draw_routes do
      localized do
        get 'people', :to => 'people#index', :as => 'people'
      end
      get 'products', :to => 'products#index', :as => 'products'
    end

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/products', :controller => 'products', :action => 'index'
    assert_unrecognized_route '/es/productos', :controller => 'products', :action => 'index', :locale => 'es'
  end

  def test_force_locale
    config_default_locale_settings 'en'
    config_force_locale true

    draw_routes do
      localized do
        get 'people', :to => 'people#index', :as => 'people'
      end
    end

    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/people', :controller => 'people', :action => 'index'
  end

  def test_generate_unlocalized_routes
    config_default_locale_settings 'en'
    config_generate_unlocalized_routes true

    draw_routes do
      localized do
        get 'people', :to => 'people#index', :as => 'people'
      end
    end

    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/people', :controller => 'people', :action => 'index'
  end

  def test_config_translation_file
    config_default_locale_settings 'es'

    draw_routes do
      localized do
        root :to => 'people#index'
      end
    end

    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
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
end
