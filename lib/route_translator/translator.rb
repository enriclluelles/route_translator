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

        RouteTranslator::ROUTE_HELPER_CONTAINER.each do |helper_container|
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

    def self.translations_for(app, conditions = {}, requirements = {}, defaults = {}, name = nil, anchor = true)
      add_untranslated_helpers_to_controllers_and_views(name)
      I18n.available_locales.each do |locale|
        new_conditions = conditions.dup
        new_conditions[:path_info] = translate_path(conditions[:path_info], locale)
        new_defaults = defaults.merge(RouteTranslator.locale_param_key => locale.to_s)
        new_requirements = requirements.merge(RouteTranslator.locale_param_key => locale.to_s)
        new_name = translate_name(name, locale)
        yield app, new_conditions, new_requirements, new_defaults, new_name, anchor
      end
    end

    # Translates a path and adds the locale prefix.
    def self.translate_path(path, locale)
      new_path = path.dup
      final_optional_segments = new_path.slice!(/(\(.+\))$/)
      new_path = new_path.split("/").map{|seg| translate_path_segment(seg, locale)}.join('/')

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

    def self.translate_name(name, locale)
      return nil unless name
      "#{name}_#{RouteTranslator.locale_suffix(locale)}"
    end

    def self.default_locale?(locale)
      I18n.default_locale.to_sym == locale.to_sym
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
      fallback = I18n.translate(str, locale: locale, default: str)
      I18n.translate("routes.#{str}", locale: locale, default: fallback)
    end
  end
end
