module RouteTranslator
  module Translator
    # Add standard route helpers for default locale e.g.
    #   I18n.locale = :de
    #   people_path -> people_de_path
    #   I18n.locale = :fr
    #   people_path -> people_fr_path
    def self.add_untranslated_helpers_to_controllers_and_views(old_name, helper_container)
      ['path', 'url'].each do |suffix|
        new_helper_name = "#{old_name}_#{suffix}"

        helper_container.__send__(:define_method, new_helper_name) do |*args|
          locale_suffix = I18n.locale.to_s.underscore
          if respond_to?("#{old_name}_#{locale_suffix}_#{suffix}")
            __send__("#{old_name}_#{locale_suffix}_#{suffix}", *args)
          else
            __send__("#{old_name}_#{I18n.default_locale.to_s.underscore}_#{suffix}", *args)
          end
        end
      end
    end

    def self.translations_for(app, conditions, requirements, defaults, route_name, anchor, route_set, &block)
      add_untranslated_helpers_to_controllers_and_views(route_name, route_set.named_routes.module)
      I18n.available_locales.each do |locale|
        new_conditions = conditions.dup
        new_conditions[:path_info] = translate_path(conditions[:path_info], locale)
        if new_conditions[:required_defaults] && !new_conditions[:required_defaults].include?(RouteTranslator.locale_param_key)
          new_conditions[:required_defaults] << RouteTranslator.locale_param_key if new_conditions[:required_defaults]
        end
        new_defaults = defaults.merge(RouteTranslator.locale_param_key => locale.to_s)
        new_requirements = requirements.merge(RouteTranslator.locale_param_key => locale.to_s)
        new_route_name = translate_name(route_name, locale)
        new_route_name = nil if new_route_name && route_set.named_routes.routes[new_route_name.to_sym] #TODO: Investigate this :(
        block.call(app, new_conditions, new_requirements, new_defaults, new_route_name, anchor)
      end
      block.call(app, conditions, requirements, defaults, route_name, anchor) if RouteTranslator.config.generate_unlocalized_routes
    end

    # Translates a path and adds the locale prefix.
    def self.translate_path(path, locale)
      new_path = path.dup
      final_optional_segments = new_path.slice!(/(\(.+\))$/)
      new_path = new_path.split("/").map{|seg| translate_path_segment(seg, locale)}.join('/')

      # Add locale prefix if it's not the default locale,
      # or forcing locale to all routes,
      # or already generating actual unlocalized routes
      if !default_locale?(locale) || RouteTranslator.config.force_locale || RouteTranslator.config.generate_unlocalized_routes
        new_path = "/#{locale.to_s.downcase}#{new_path}"
      end

      new_path = "/" if new_path.blank?

      "#{new_path}#{final_optional_segments}"
    end

    def self.translate_name(n, locale)
      "#{n}_#{locale.to_s.underscore}" if n.present?
    end

    def self.default_locale?(locale)
      I18n.default_locale.to_sym == locale.to_sym
    end

    # Tries to translate a single path segment. If the path segment
    # contains sth. like a optional format "people(.:format)", only
    # "people" will be translated, if there is no translation, the path
    # segment is blank, begins with a ":" (param key) or "*" (wildcard),
    # the segment is returned untouched
    def self.translate_path_segment segment, locale
      return segment if segment.blank? or segment.starts_with?(":") or segment.starts_with?("*")

      match = TRANSLATABLE_SEGMENT.match(segment)[1] rescue nil

      (translate_string(match, locale) || segment)
    end

    def self.translate_string(str, locale)
      res = I18n.translate(str, :scope => :routes, :locale => locale, :default => str)
      URI.escape(res)
    end
  end
end
