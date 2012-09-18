require 'test/unit'
require 'mocha'

require 'route_translator'

require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))


class PeopleController < ActionController::Base;  end
class ProductsController < ActionController::Base;  end

class TranslateRoutesTest < ActionController::TestCase
  include ActionDispatch::Assertions::RoutingAssertions
  include RouteTranslator::TestHelper

  def config_default_locale_settings(locale)
    I18n.default_locale = locale
  end

  def config_force_locale(boolean)
    RouteTranslator.config.force_locale = boolean
  end

  def config_generate_unlocalized_routes(boolean)
    RouteTranslator.config.generate_unlocalized_routes = boolean
  end

  def setup
    @controller = ActionController::Base.new
    @view = ActionView::Base.new
    @routes = ActionDispatch::Routing::RouteSet.new
  end

  def teardown
    config_force_locale false
    config_generate_unlocalized_routes false
  end

  def test_unnamed_root_route
    @routes.draw do
      localized do
        root :to => 'people#index'
      end
    end
    config_default_locale_settings 'en'
    @routes.translate_with_dictionary{|t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_unnamed_root_route_without_prefix
    @routes.draw do
      localized do
        root :to => 'people#index'
      end
    end
    config_default_locale_settings 'es'

    @routes.translate_from_file(File.expand_path('locales/routes.yml', File.dirname(__FILE__)))

    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_unnamed_untranslated_route
    @routes.draw do
      localized do
        match 'foo', :to => 'people#index'
      end
    end
    config_default_locale_settings 'en'
    @routes.translate_with_dictionary{|t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/es/foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/foo', :controller => 'people', :action => 'index', :locale => 'en'
  end

  def test_unnamed_translated_route_on_default_locale
    @routes.draw { match 'people', :to => 'people#index' }
    @routes.draw do
      localized do
        match 'people', :to => 'people#index'
      end
    end

    config_default_locale_settings 'es'

    @routes.translate_with_dictionary{|t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/gente', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_unnamed_translated_route_on_non_default_locale
    @routes.draw do
      localized do
        match 'people', :to => 'people#index'
      end
    end
    config_default_locale_settings 'en'
    @routes.translate_with_dictionary{|t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
  end

  def test_named_translated_route_with_prefix_must_have_locale_as_static_segment
    @routes.draw do
      localized do
        match 'people', :to => 'people#index'
      end
    end
    config_default_locale_settings 'en'
    @routes.translate_with_dictionary{|t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    # we check the string representation of the route,
    # if it stores locale as a dynamic segment it would be represented as: "/:locale/gente"
    assert_equal "/es/gente(.:format)", path_string(named_route('people_es'))
  end

  def test_named_empty_route_without_prefix
    @routes.draw do
      localized do
        root :to => 'people#index', :as => 'people'
      end
    end
    config_default_locale_settings 'es'
    @routes.translate_with_dictionary{|t|  t['es'] = {};  t['en'] = {'people' => 'gente'}; }

    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_named_root_route_without_prefix
    @routes.draw do
      localized do
        root :to => 'people#index'
      end
    end

    config_default_locale_settings 'es'

    @routes.translate_from_file(File.expand_path('locales/routes.yml', File.dirname(__FILE__)))

    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end

  def test_named_untranslated_route_without_prefix
    @routes.draw do
      localized do
        match 'foo', :to => 'people#index', :as => 'people'
      end
    end
    config_default_locale_settings 'es'
    @routes.translate_with_dictionary{ |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/en/foo', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_named_translated_route_on_default_locale_without_prefix
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end

    config_default_locale_settings 'es'

    @routes.translate_with_dictionary{|t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing 'gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_named_translated_route_on_non_default_locale_without_prefix
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end

    config_default_locale_settings 'en'

    @routes.translate_with_dictionary{|t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_formatted_root_route
    @routes.draw do
      localized do
        root :to => 'people#index', :as => 'root'
      end
    end

    @routes.translate_with_dictionary{ |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    if formatted_root_route?
      assert_equal '/(.:format)', path_string(named_route('root_en'))
      assert_equal '/es(.:format)', path_string(named_route('root_es'))
    else
      assert_equal '/', path_string(named_route('root_en'))
      assert_equal '/es', path_string(named_route('root_es'))
    end
  end

  def test_routes_locale_prefixes_are_never_downcased
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end
    config_default_locale_settings 'en'

    @routes.translate_with_dictionary{ |t| t['en'] = {}; t['ES'] = {'people' => 'Gente'} }

    assert_routing '/es/Gente', :controller => 'people', :action => 'index', :locale => 'ES'
  end

  def test_languages_load_from_file
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end
    config_default_locale_settings 'en'

    @routes.translate_from_file(File.expand_path('locales/routes.yml', File.dirname(__FILE__)))

    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_languages_load_from_file_without_dictionary_for_default_locale
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end
    config_default_locale_settings 'fr'

    @routes.translate_from_file(File.expand_path('locales/routes.yml', File.dirname(__FILE__)))

    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'fr'
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_fr, :people_en, :people_es, :people
  end

  def test_i18n_based_translations_setting_locales
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end
    config_default_locale_settings 'en'

    I18n.backend = StubbedI18nBackend

    @routes.translate_with_i18n('es')

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_i18n_based_translations_taking_i18n_available_locales
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end
    config_default_locale_settings 'en'
    I18n.stubs(:available_locales).at_least_once.returns StubbedI18nBackend.available_locales
    I18n.backend = StubbedI18nBackend

    @routes.translate_with_i18n

    assert_routing '/fr/people', :controller => 'people', :action => 'index', :locale => 'fr'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_helpers_include :people_fr, :people_en, :people_es, :people
  end

  def test_2_localized_blocks
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
      localized do
        match 'products', :to => 'products#index', :as => 'products'
      end
    end
    config_default_locale_settings 'en'

    @routes.translate_from_file(File.expand_path('locales/routes.yml', File.dirname(__FILE__)))

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/es/productos', :controller => 'products', :action => 'index', :locale => 'es'
  end

  def test_not_localizing_routes_outside_blocks
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
      match 'products', :to => 'products#index', :as => 'products'
    end
    config_default_locale_settings 'en'

    @routes.translate_from_file(File.expand_path('locales/routes.yml', File.dirname(__FILE__)))

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/products', :controller => 'products', :action => 'index'
    assert_unrecognized_route '/es/productos', :controller => 'products', :action => 'index', :locale => 'es'
  end

  def test_force_locale
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end

    config_default_locale_settings 'en'
    config_force_locale true

    @routes.translate_from_file(File.expand_path('locales/routes.yml', File.dirname(__FILE__)))

    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/people', :controller => 'people', :action => 'index'
  end

  def test_generate_unlocalized_routes
    @routes.draw do
      localized do
        match 'people', :to => 'people#index', :as => 'people'
      end
    end

    config_default_locale_settings 'en'
    config_generate_unlocalized_routes true

    @routes.translate_from_file(File.expand_path('locales/routes.yml', File.dirname(__FILE__)))

    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/people', :controller => 'people', :action => 'index'
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
