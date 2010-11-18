require 'test/unit'
require 'rubygems'
require 'mocha'

%w(actionpack activesupport actionmailer).each{ |gem_lib| gem gem_lib, '3.0.1' }
%w(active_support action_pack action_mailer action_controller action_dispatch).each{ |lib| require lib }

plugin_root = File.join(File.dirname(__FILE__), '..')
require "#{plugin_root}/lib/route_translator"


class PeopleController < ActionController::Base;  end

class TranslateRoutesTest < ActionController::TestCase
  include ActionDispatch::Assertions::RoutingAssertions

  def config_default_locale_settings(locale)
    I18n.default_locale = locale
  end

  def translate_routes
    @route_translator.translate @routes
    @routes.finalize!
    @routes.named_routes.install
  end

  def setup
    @controller = ActionController::Base.new
    @view = ActionView::Base.new
    @routes = ActionDispatch::Routing::RouteSet.new
    @route_translator = RouteTranslator.new
  end

  def test_unnamed_root_route
    @routes.draw { root :to => 'people#index' }
    config_default_locale_settings 'en'
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    translate_routes
  
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_unnamed_root_route_without_prefix
    @routes.draw { root :to => 'people#index' }
    config_default_locale_settings 'es'
    @route_translator.load_dictionary_from_file File.expand_path('locales/routes.yml', File.dirname(__FILE__))
    translate_routes
  
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_unnamed_untranslated_route
    @routes.draw { match 'foo', :to => 'people#index' }
    config_default_locale_settings 'en'
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    translate_routes
  
    assert_routing '/es/foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/foo', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  def test_unnamed_translated_route_on_default_locale
    @routes.draw { match 'people', :to => 'people#index' }
    config_default_locale_settings 'es'
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    translate_routes
  
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/gente', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_unnamed_translated_route_on_non_default_locale
    @routes.draw { match 'people', :to => 'people#index' }
    config_default_locale_settings 'en'
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    translate_routes
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  def test_named_translated_route_with_prefix_must_have_locale_as_static_segment
    @routes.draw { match 'people', :to => 'people#index', :as => 'people' }
    config_default_locale_settings 'en'
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    translate_routes
    
    # we check the string representation of the route,
    # if it stores locale as a dynamic segment it would be represented as: "/:locale/gente"
    assert_equal "/es/gente(.:format)", path_string(named_route('people_es'))
  end
  
  def test_named_empty_route_without_prefix
    @routes.draw { root :to => 'people#index', :as => 'people' }
    config_default_locale_settings 'es'
    @route_translator.yield_dictionary { |t|  t['es'] = {};  t['en'] = {'people' => 'gente'}; }
    translate_routes
  
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_named_root_route_without_prefix
    @routes.draw { root :to => 'people#index' }
    config_default_locale_settings 'es'
    @route_translator.load_dictionary_from_file File.expand_path('locales/routes.yml', File.dirname(__FILE__))
    translate_routes
  
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_named_untranslated_route_without_prefix
    @routes.draw { match 'foo', :to => 'people#index', :as => 'people' }
    config_default_locale_settings 'es'
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    translate_routes
  
    assert_routing '/en/foo', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing 'foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_named_translated_route_on_default_locale_without_prefix
    @routes.draw { match 'people', :to => 'people#index', :as => 'people'}
    config_default_locale_settings 'es'
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    translate_routes
  
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing 'gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_named_translated_route_on_non_default_locale_without_prefix
    @routes.draw { match 'people', :to => 'people#index', :as => 'people'}
    config_default_locale_settings 'en'
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    translate_routes
  
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end

  def test_formatted_root_route
    @routes.draw{ root :to => 'people#index', :as => 'root' }
    @route_translator.yield_dictionary { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    assert_equal '/(.:format)', path_string(named_route('root'))
    translate_routes
    assert_equal '/(.:format)', path_string(named_route('root_en'))
    assert_equal '/es(.:format)', path_string(named_route('root_es'))
  end
  
  
  def test_languages_load_from_file
    @routes.draw { match 'people', :to => 'people#index', :as => 'people'}
    config_default_locale_settings 'en'
    @route_translator.load_dictionary_from_file File.expand_path('locales/routes.yml', File.dirname(__FILE__))
    translate_routes
  
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_languages_load_from_file_without_dictionary_for_default_locale
    @routes.draw { match 'people', :to => 'people#index', :as => 'people'}
    config_default_locale_settings 'fr'
    @route_translator.load_dictionary_from_file File.expand_path('locales/routes.yml', File.dirname(__FILE__))
    translate_routes
  
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'fr'
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_fr, :people_en, :people_es, :people
  end
  
  def test_i18n_based_translations_setting_locales
    @routes.draw { match 'people', :to => 'people#index', :as => 'people'}
    config_default_locale_settings 'en'
    I18n.backend = StubbedI18nBackend
    @route_translator.init_i18n_dictionary 'es'
    translate_routes
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_i18n_based_translations_taking_i18n_available_locales
    @routes.draw { match 'people', :to => 'people#index', :as => 'people'}
    config_default_locale_settings 'en'
    I18n.stubs(:available_locales).at_least_once.returns StubbedI18nBackend.available_locales
    I18n.backend = StubbedI18nBackend
    @route_translator.init_i18n_dictionary
    translate_routes
  
    assert_routing '/fr/people', :controller => 'people', :action => 'index', :locale => 'fr'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_helpers_include :people_fr, :people_en, :people_es, :people
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

  private

  # Given a route defined as a string like this:
  # 'ANY    /es(.:format)                            {:controller=>"people", :action=>"index"}'
  # returns "/es(.:format)"
  def path_string(route)
    route.to_s.split(' ')[1]
  end

  def named_route(name)
    @routes.routes.select{ |r| r.name == name }.first
  end

  def assert_helpers_include(*helpers)
    helpers.each do |helper|
      ['url', 'path'].each do |suffix|
        [@controller, @view].each { |obj| assert_respond_to obj, "#{helper}_#{suffix}".to_sym }
      end
    end
  end

  def assert_unrecognized_route(route_path, options)
    assert_raise ActionController::RoutingError do
      assert_routing route_path, options
    end
  end

  class StubbedI18nBackend


    @@translations = {
      'es' => { 'people' => 'gente'},
      'fr' => {} # empty on purpose to test behaviour on incompleteness scenarios
    }

    def self.translate(locale, key, options)
      @@translations[locale.to_s][key] || options[:default]
    rescue
      options[:default]
    end

    def self.available_locales
      @@translations.keys
    end

  end

end
