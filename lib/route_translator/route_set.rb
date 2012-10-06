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
      file_path = absolute_path(file_path)

      reset_dictionary
      Dir[file_path].each do |file|
        add_dictionary_from_file(file)
      end
      translate
    end

private

    def absolute_path (file_path)
      file_path ||= RouteTranslator.config.translation_file
      file_path = Rails.root.join(file_path) if defined?(Rails)
      file_path
    end

public

    include Helpers
    include Translator
    include DictionaryManagement
  end
end
