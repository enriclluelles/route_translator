plugin_root = File.join(File.dirname(__FILE__), '..')
app_root = plugin_root + '/../../..'

require 'test/unit'

ENV['RAILS_ENV'] = 'test'
require File.expand_path(app_root + '/config/boot')
require 'action_controller'
require 'action_controller/test_process'
require 'active_support'

require "#{plugin_root}/lib/translate_routes"
RAILS_ROOT = '.'

class PeopleController < ActionController::Base;  end

class TranslateRoutesTest < Test::Unit::TestCase

  def setup
    @controller = ActionController::Base.new
    @view = ActionView::Base.new
  end

  # Unnamed routes, prefix

  def test_unnamed_empty_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect '', :controller => 'people', :action => 'index' }
    set_default_lang_details('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :lang => 'en'
  end
  
  def test_unnamed_untranslated_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'foo', :controller => 'people', :action => 'index' }
    set_default_lang_details('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/foo', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/en/foo', :controller => 'people', :action => 'index', :lang => 'en'
  end
  
  def test_unnamed_translated_route_on_default_language_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    set_default_lang_details('es', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :lang => 'es'    
  end

  def test_unnamed_translated_route_on_non_default_language_with_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'people', :controller => 'people', :action => 'index' }
    set_default_lang_details('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/en/people', :controller => 'people', :action => 'index', :lang => 'en'    
  end


  # Unnamed routes, non-prefix

  def test_unnamed_empty_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.connect '', :controller => 'people', :action => 'index' }
    set_default_lang_details('en', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/', :controller => 'people', :action => 'index', :lang => 'en'
  end
  
  def test_unnamed_untranslated_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.connect 'foo', :controller => 'people', :action => 'index'}
    set_default_lang_details('en', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
    
    assert_routing '/es/foo', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/foo', :controller => 'people', :action => 'index', :lang => 'en'
  end
  
  def test_unnamed_translated_route_on_default_language_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    set_default_lang_details('es', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/en/people', :controller => 'people', :action => 'index', :lang => 'en'
    assert_routing 'gente', :controller => 'people', :action => 'index', :lang => 'es'
  end

  def test_unnamed_translated_route_on_non_default_language_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    set_default_lang_details('en', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/es/gente', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/people', :controller => 'people', :action => 'index', :lang => 'en'
  end

  # Named routes, prefix

  def test_named_empty_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people '', :controller => 'people', :action => 'index' }
    set_default_lang_details('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/en', :controller => 'people', :action => 'index', :lang => 'en'
    assert_helpers_include :people_en, :people_es, :people    
  end
  
  def test_named_untranslated_route_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'foo', :controller => 'people', :action => 'index'}
    set_default_lang_details('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/foo', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/en/foo', :controller => 'people', :action => 'index', :lang => 'en'
    assert_helpers_include :people_en, :people_es, :people    
  end
  
  def test_named_translated_route_on_default_language_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    set_default_lang_details('es', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/en/people', :controller => 'people', :action => 'index', :lang => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :lang => 'es'
    assert_helpers_include :people_es, :people    
  end

  def test_named_translated_route_on_non_default_language_with_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index' }
    set_default_lang_details('en', true)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '/en/people', :controller => 'people', :action => 'index', :lang => 'en'
    assert_helpers_include :people_en, :people_es, :people    
  end
  
  # Named routes, non-prefix

  def test_named_empty_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people '', :controller => 'people', :action => 'index'}
    set_default_lang_details('es', false)
    ActionController::Routing::Translator.translate { |t|  t['es'] = {};  t['en'] = {'people' => 'gente'}; }

    assert_routing '/en', :controller => 'people', :action => 'index', :lang => 'en'
    assert_routing '/', :controller => 'people', :action => 'index', :lang => 'es'
    assert_routing '', :controller => 'people', :action => 'index', :lang => 'es'
  end
  
  def test_named_untranslated_route_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'foo', :controller => 'people', :action => 'index'}
    set_default_lang_details('es', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }

    assert_routing '/en/foo', :controller => 'people', :action => 'index', :lang => 'en'
    assert_routing 'foo', :controller => 'people', :action => 'index', :lang => 'es'
    assert_helpers_include :people_es, :people    
  end
  
  def test_named_translated_route_on_default_language_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    set_default_lang_details('es', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/en/people', :controller => 'people', :action => 'index', :lang => 'en'
    assert_routing 'gente', :controller => 'people', :action => 'index', :lang => 'es'
    assert_helpers_include :people_es, :people
  end

  def test_named_translated_route_on_non_default_language_without_prefix
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    set_default_lang_details('en', false)
    ActionController::Routing::Translator.translate { |t| t['en'] = {}; t['es'] = {'people' => 'gente'} }
  
    assert_routing '/people', :controller => 'people', :action => 'index', :lang => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :lang => 'es'
    assert_helpers_include :people_es, :people
  end

  def test_languages_load_from_files
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    set_default_lang_details('en', false)
    ActionController::Routing::Translator.translate_from_files
    
    assert_routing '/people', :controller => 'people', :action => 'index', :lang => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :lang => 'es'
    assert_helpers_include :people_es, :people
    assert_helpers_include :people_en, :people    
  end
  
  def test_languages_load_from_files_without_file_for_default_language
    ActionController::Routing::Routes.draw { |map| map.people 'people', :controller => 'people', :action => 'index'}
    set_default_lang_details('fr', false)
    ActionController::Routing::Translator.translate_from_files
    
    assert_routing '/people', :controller => 'people', :action => 'index', :lang => 'fr'
    assert_routing '/en/people', :controller => 'people', :action => 'index', :lang => 'en'
    assert_routing '/es/gente', :controller => 'people', :action => 'index', :lang => 'es'
    assert_helpers_include :people_es, :people_en, :people_fr, :people
  end

  private
  
  def assert_helpers_include(*helpers)
    helpers.each do |helper|
      ['_url', '_path'].each do |suffix|    
        [@controller, @view].each { |obj| assert_respond_to obj, "#{helper}#{suffix}".to_sym }
      end
    end
    
  end

  def set_default_lang_details(lang, with_prefix)
    ActionController::Routing::Translator.default_lang = lang
    ActionController::Routing::Translator.prefix_on_default_lang = with_prefix
  end
  
end
