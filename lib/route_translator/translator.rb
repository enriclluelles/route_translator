module RouteTranslator
  module Translator
    # Add standard route helpers for default locale e.g.
    #   I18n.locale = :de
    #   people_path -> people_de_path
    #   I18n.locale = :fr
    #   people_path -> people_fr_path
    def self.add_untranslated_helpers_to_controllers_and_views(old_name, named_route_collection)
      if (named_route_collection.respond_to?(:url_helpers_module))
        url_helpers_module = named_route_collection.url_helpers_module
        path_helpers_module = named_route_collection.path_helpers_module
        url_helpers_list = named_route_collection.helper_names
        path_helpers_list = named_route_collection.helper_names
      else
        url_helpers_module = named_route_collection.module
        path_helpers_module = named_route_collection.module
        url_helpers_list = named_route_collection.helpers
        path_helpers_list = named_route_collection.helpers
      end

      [
        ['path', path_helpers_module, path_helpers_list],
        ['url', url_helpers_module, url_helpers_list]
      ].each do |suffix, helper_container, helper_list|
        new_helper_name = "#{old_name}_#{suffix}"

        helper_list.push(new_helper_name.to_sym) unless helper_list.include?(new_helper_name.to_sym)

        helper_container.__send__(:define_method, new_helper_name) do |*args|
          __send__(Translator.route_name_for(args, old_name, suffix, self), *args)
        end
      end
    end

    def self.translations_for(app, conditions, requirements, defaults, route_name, anchor, route_set, &block)
      add_untranslated_helpers_to_controllers_and_views(route_name, route_set.named_routes)

      available_locales.each do |locale|
        new_conditions = conditions.dup
        new_conditions[:path_info] = translate_path(conditions[:path_info], locale)
        new_conditions[:parsed_path_info] = ActionDispatch::Journey::Parser.new.parse(new_conditions[:path_info]) if conditions[:parsed_path_info]
        if new_conditions[:required_defaults] && !new_conditions[:required_defaults].include?(RouteTranslator.locale_param_key)
          new_conditions[:required_defaults] << RouteTranslator.locale_param_key
        end
        new_defaults = defaults.merge(RouteTranslator.locale_param_key => locale.to_s.gsub('native_', ''))
        new_requirements = requirements.merge(RouteTranslator.locale_param_key => locale.to_s)
        new_route_name = translate_name(route_name, locale)
        new_route_name = nil if new_route_name && route_set.named_routes.routes[new_route_name.to_sym] #TODO: Investigate this :(
        block.call(app, new_conditions, new_requirements, new_defaults, new_route_name, anchor)
      end
      if RouteTranslator.config.generate_unnamed_unlocalized_routes
        block.call(app, conditions, requirements, defaults, nil, anchor)
      elsif RouteTranslator.config.generate_unlocalized_routes
        block.call(app, conditions, requirements, defaults, route_name, anchor)
      end
    end

    private
    def self.available_locales
      available_locales = config_locales || I18n.available_locales.dup
      available_locales.push(*RouteTranslator.native_locales) if RouteTranslator.native_locales.present?
      # Make sure the default locale is translated in last place to avoid
      # problems with wildcards when default locale is omitted in paths. The
      # default routes will catch all paths like wildcard if it is translated first.
      available_locales.push(available_locales.delete(I18n.default_locale))
    end

    def self.config_locales
      if RouteTranslator.config.available_locales
        RouteTranslator.config.available_locales.map{|l| l.to_sym}
      end
    end

    # Translates a path and adds the locale prefix.
    def self.translate_path(path, locale)
      new_path = path.dup
      final_optional_segments = new_path.slice!(/(\([^\/]+\))$/)
      translated_segments = new_path.split(/\/|\./).map{ |seg| translate_path_segment(seg, locale) }.select{ |seg| !seg.blank? }

      if display_locale?(locale) && !locale_param_present?(new_path)
        translated_segments.unshift(locale.to_s.downcase)
      end

      joined_segments = translated_segments.inject do |memo, segment|
        separator = segment == ':format' ? '.' : '/'
        memo << separator << segment
      end

      "/#{joined_segments}#{final_optional_segments}".gsub(/\/\(\//, '(/')
    end

    def self.display_locale?(locale)
      !RouteTranslator.config.hide_locale && !RouteTranslator.native_locale?(locale) &&
        (!default_locale?(locale) ||
         RouteTranslator.config.force_locale ||
         RouteTranslator.config.generate_unlocalized_routes ||
         RouteTranslator.config.generate_unnamed_unlocalized_routes)
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
    def self.translate_path_segment(segment, locale)
      return segment if segment.blank? or segment.starts_with?(":") or segment.starts_with?("(") or segment.starts_with?("*")

      appended_part = segment.slice!(/(\()$/)
      match = TRANSLATABLE_SEGMENT.match(segment)[1] rescue nil

      (translate_string(match, locale) || segment) + appended_part.to_s
    end

    def self.translate_string(str, locale)
      locale = "#{locale}".gsub('native_', '')
      res    = I18n.translate(str, :scope => :routes, :locale => locale, :default => str)
      URI.escape(res)
    end

    def self.locale_param_present?(path)
      !(path.split('/').detect { |segment| segment.to_s == ":#{RouteTranslator.locale_param_key.to_s}" }.nil?)
    end

    def self.host_locales_option?
      RouteTranslator.config.host_locales.present?
    end

    def self.route_name_for(args, old_name, suffix, kaller)
      args_hash          = args.detect{|arg| arg.is_a?(Hash)}
      args_locale = host_locales_option? && args_hash && args_hash[:locale]
      current_locale_name = I18n.locale.to_s.underscore

      locale = if args_locale
                 args_locale.to_s.underscore
               elsif kaller.respond_to?("#{old_name}_#{current_locale_name}_#{suffix}")
                 current_locale_name
               else
                 I18n.default_locale.to_s.underscore
               end

      "#{old_name}_#{locale}_#{suffix}"
    end
  end
end
