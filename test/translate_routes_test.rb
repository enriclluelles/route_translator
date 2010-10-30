require 'test/unit'
require 'rubygems'

%w(actionpack activesupport actionmailer).each{ |gem_lib| gem gem_lib, '2.3.10' }
%w(activesupport actionpack actionmailer action_controller).each{ |lib| require lib }

plugin_root = File.join(File.dirname(__FILE__), '..')
require "#{plugin_root}/lib/translate_routes"
RAILS_ROOT = plugin_root

class PeopleController < ActionController::Base;  end

class TranslateRoutesTest < ActionController::TestCase

  include ActionController::Assertions::RoutingAssertions

  def setup
    @controller = ActionController::Base.new
    @view = ActionView::Base.new
    ActionController::Routing::Routes.clear!
  end


  # Unnamed routes with prefix on default locale:

  def test_unnamed_empty_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect '', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  def test_unnamed_root_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect '/', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', true)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'
  
    assert_routing '/', :controller => 'people', :action => 'index'
    assert_routing '/es', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  def test_unnamed_untranslated_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'foo', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en/foo', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  def test_unnamed_translated_route_on_default_locale_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'    
  end
    
  def test_unnamed_translated_route_on_non_default_locale_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'people', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'    
  end
  
  
  # Unnamed routes without prefix on default locale:
  
  def test_unnamed_empty_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.connect '', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  def test_unnamed_root_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.connect '/', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', false)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'
  
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_unnamed_untranslated_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'foo', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    
    assert_routing '/es/foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/foo', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  def test_unnamed_translated_route_on_default_locale_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing 'gente', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_unnamed_translated_route_on_non_default_locale_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  
  # Named routes with prefix on default locale:
  
  def test_named_empty_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people '', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_named_root_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.root :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', true)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'
  
    assert_routing '/', :controller => 'people', :action => 'index'
    assert_routing '/es', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
  end
  
  def test_named_untranslated_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'foo', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en/foo', :controller => 'people', :action => 'index', :locale => 'en'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_named_translated_route_on_default_locale_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_named_translated_route_on_non_default_locale_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index' }
    config_default_locale_settings('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  # Named routes without prefix on default locale:
  
  def test_named_empty_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people '', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', false)
    ActionController::Routing::Translator.translate { |t|  t['es'] = {};  t['en'] = {'people' => 'gente'}; }
  
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_named_root_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.root :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', false)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'
  
    assert_routing '/', :controller => 'people', :action => 'index', :locale => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :locale => 'en'
    assert_unrecognized_route '/es', :controller => 'people', :action => 'index', :locale => 'es'
  end
  
  def test_named_untranslated_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'foo', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/en/foo', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing 'foo', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_named_translated_route_on_default_locale_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('es', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing 'gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_named_translated_route_on_non_default_locale_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_languages_load_from_file
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en', false)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'
    
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_languages_load_from_file_without_dictionary_for_default_locale
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('fr', false)
    ActionController::Routing::Translator.translate_from_file 'test', 'locales', 'routes.yml'
    
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'fr'
    assert_routing '/en/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_fr, :people_en, :people_es, :people
  end
  
  def test_i18n_based_translations_setting_locales
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en', false)
    I18n.backend = StubbedI18nBackend
    ActionController::Routing::Translator.i18n('es')
  
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'    
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
    assert_helpers_include :people_en, :people_es, :people
  end
  
  def test_i18n_based_translations_taking_i18n_available_locales
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    config_default_locale_settings('en', false)
    I18n.stubs(:available_locales).at_least_once.returns StubbedI18nBackend.available_locales
    I18n.backend = StubbedI18nBackend
    ActionController::Routing::Translator.i18n
  
    assert_routing '/people', :controller => 'people', :action => 'index', :locale => 'en'
    assert_routing '/fr/people', :controller => 'people', :action => 'index', :locale => 'fr'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :locale => 'es'
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
  
  def assert_helpers_include(*helpers)
    helpers.each do |helper|
      ['_url', '_path'].each do |suffix|    
        [@controller, @view].each { |obj| assert_respond_to obj, "#{helper}#{suffix}".to_sym }
      end
    end
  end
  
  def assert_unrecognized_route(route_path, options)
    assert_raise ActionController::RoutingError do
      assert_routing route_path, options
    end
  end

  def config_default_locale_settings(locale, with_prefix)
    I18n.default_locale = locale
    ActionController::Routing::Translator.prefix_on_default_locale = with_prefix
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
