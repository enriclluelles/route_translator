ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  fixtures :all
end

# include default lang on your test requests (test requests doesn't support default_url_options):
module ActionController
  module TestProcess
    unless method_defined?(:process_without_default_locale)
      def process_with_default_locale(action, parameters = nil, session = nil, flash = nil)
        lang_pair = {ActionController::Routing::Translator.locale_param_key => ActionController::Routing::Translator.default_locale}
        parameters = lang_pair.merge(parameters) rescue lang_pair
        process_without_default_locale(action, parameters, session, flash)
      end
    
      alias :process_without_default_locale :process
      alias :process :process_with_default_locale
    end
  end
end