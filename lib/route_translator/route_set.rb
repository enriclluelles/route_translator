%w(helpers translator dictionary_management).each do |f|
  require File.expand_path(File.join(File.dirname(__FILE__), 'route_set', f))
end


module RouteTranslator
  module RouteSet
    include DictionaryManagement
    include Translator

    attr_accessor :dictionary, :localized_routes

    #Use the i18n setting from the app
    def translate_with_i18n(*wanted_locales)
      init_i18n_dictionary(*wanted_locales)
      translate
    end

    #Use yield the block passing and empty dictionary as a paramenter
    def translate_with_dictionary(&block)
      yield_dictionary &block
      translate
    end

    #Use the translations from the specified file
    def translate_from_file(file_path = nil)
      file_path ||= defined?(Rails) && File.join(Rails.root, %w(config i18n-routes.yml))
      reset_dictionary
      Dir[file_path].each do |file|
        add_dictionary_from_file(file)
      end
      translate
    end

    include Helpers
    include Translator
    include DictionaryManagement
  end
end
