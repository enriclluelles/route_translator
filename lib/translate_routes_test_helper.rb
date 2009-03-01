# Author: Raul Murciano [http://raul.murciano.net] for Domestika [http://domestika.org]
# Copyright (c) 2007, Released under the MIT license (see MIT-LICENSE)

require 'test_help'

# Include default lang on your test requests (test requests doesn't support default_url_options):
ActionController::TestProcess.class_eval do
  unless method_defined?(:process_without_default_language)
    def process_with_default_language(action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
      lang_pair = {:locale, I18n.default_locale.to_s}
      parameters = lang_pair.merge(parameters) rescue lang_pair
      process_without_default_language(action, parameters, session, flash, http_method)
    end

    alias :process_without_default_language :process
    alias :process :process_with_default_language
  end
end

# Add untranslated helper for named routes to integration tests
ActionController::Integration::Session.class_eval do
  ['path', 'url'].each do |suffix|
    ActionController::Routing::Translator.original_names.each do |old_name|
      new_helper_name = "#{old_name}_#{suffix}"
      def_new_helper = <<-DEF_NEW_HELPER
        def #{new_helper_name}(*args)                      
          send("#{old_name}_#{ActionController::Routing::Translator.locale_suffix(I18n.default_locale)}_#{suffix}", *args)
        end
      DEF_NEW_HELPER
      eval def_new_helper
    end
  end
end
