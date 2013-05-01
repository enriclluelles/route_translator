module RouteTranslator
  module Translator
    # Add standard route helpers for default locale e.g.
    #   I18n.locale = :de
    #   people_path -> people_de_path
    #   I18n.locale = :fr
    #   people_path -> people_fr_path
    def self.add_untranslated_helpers_to_controllers_and_views old_name
      ['path', 'url'].map do |suffix|
        new_helper_name = "#{old_name}_#{suffix}"

        ROUTE_HELPER_CONTAINER.each do |helper_container|
          helper_container.send :define_method, new_helper_name do |*args|
            if respond_to? "#{old_name}_#{locale_suffix(I18n.locale)}_#{suffix}"
              send "#{old_name}_#{locale_suffix(I18n.locale)}_#{suffix}", *args
            else
              send "#{old_name}_#{locale_suffix(I18n.default_locale)}_#{suffix}", *args
            end
          end
        end

        new_helper_name.to_sym
      end
    end

    def self.add_translated_routes(path, route_set)
      path_info = conditions[:path_info]
      I18n.available_locales.each do |locale|
        conditions[:path_info] = translate_path(path_info, locale)
        route_set.add_route(app, conditions, requirements, defaults, name, anchor)
      end
    end

    # Translates a path and adds the locale prefix.
    def self.translate_path(path, locale)
      final_optional_segments = path.slice!(/(\(.+\))$/)
      new_path = path.split("/").map{|seg| translate_path_segment(seg, locale)}.join('/')

      # Add locale prefix if it's not the default locale,
      # or forcing locale to all routes,
      # or already generating actual unlocalized routes
      if !default_locale?(locale) ||
        RouteTranslator.config.force_locale ||
        RouteTranslator.config.generate_unlocalized_routes
        new_path = "/#{locale.downcase}#{new_path}"
      end

      new_path = "/" if new_path.blank?
      "#{new_path}#{final_optional_segments}"
    end

    # Tries to translate a single path segment. If the path segment
    # contains sth. like a optional format "people(.:format)", only
    # "people" will be translated, if there is no translation, the path
    # segment is blank or begins with a ":" (param key), the segment
    # is returned untouched
    def self.translate_path_segment segment, locale
      return segment if segment.blank? or segment.starts_with?(":")

      match = TRANSLATABLE_SEGMENT.match(segment)[1] rescue nil

      (translate_string(match, locale) || segment)
    end

    def self.translate_string(str, locale)
      I18n.translate(str, locale: locale, default: str)
    end
  end
end
