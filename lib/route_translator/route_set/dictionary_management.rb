module RouteTranslator
  module RouteSet
    module DictionaryManagement
      # Resets dictionary and yields the block wich can be used to manually fill the dictionary
      # with translations e.g.
      #   route_translator = RouteTranslator.new
      #   route_translator.yield_dictionary do |dict|
      #     dict['en'] = { 'people' => 'people' }
      #     dict['de'] = { 'people' => 'personen' }
      #   end
      def yield_dictionary &block
        reset_dictionary
        yield @dictionary
        set_available_locales_from_dictionary
      end

      # Resets dictionary and loads translations from specified file
      # config/locales/routes.yml:
      #   en:
      #     people: people
      #   de:
      #     people: personen
      # routes.rb:
      #   ... your routes ...
      #   ActionDispatch::Routing::Translator.translate_from_file
      # or, to specify a custom file
      #   ActionDispatch::Routing::Translator.translate_from_file 'config', 'locales', 'routes.yml'
      def load_dictionary_from_file file_path
        reset_dictionary
        add_dictionary_from_file file_path
      end

      # Add translations from another file to the dictionary.
      def add_dictionary_from_file file_path
        yaml = YAML.load_file(file_path)
        yaml.each_pair do |locale, translations|
          merge_translations locale, translations
        end
        set_available_locales_from_dictionary
      end

      # Merge translations for a specified locale into the dictionary
      def merge_translations locale, translations
        locale = locale.to_s
        if translations.blank?
          @dictionary[locale] ||= {}
          return
        end
        @dictionary[locale] = (@dictionary[locale] || {}).merge(translations)
      end

      # Init dictionary to use I18n to translate route parts. Creates
      # a hash with a block for each locale to lookup keys in I18n dynamically.
      def init_i18n_dictionary *wanted_locales
        wanted_locales = available_locales if wanted_locales.blank?
        reset_dictionary
        wanted_locales.each do |locale|
          @dictionary[locale] = Hash.new do |hsh, key|
            hsh[key] = I18n.translate key, :locale => locale #DISCUSS: caching or no caching (store key and translation in dictionary?)
          end
        end
        @available_locales = @dictionary.keys.map &:to_s
      end

      private
      def set_available_locales_from_dictionary
        @available_locales = @dictionary.keys.map &:to_s
      end

      # Resets dictionary
      def reset_dictionary
        @dictionary = { default_locale => {}}
      end
    end
  end
end
