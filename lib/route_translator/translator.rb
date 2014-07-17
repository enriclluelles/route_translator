module RouteTranslator
  module Translator
    # Add standard route helpers for default locale e.g.
    #   I18n.locale = :de
    #   people_path -> people_de_path
    #   I18n.locale = :fr
    #   people_path -> people_fr_path
    def self.add_untranslated_helpers_to_controllers_and_views(old_name, helper_container, helper_list)
      ['path', 'url'].each do |suffix|
        new_helper_name = "#{old_name}_#{suffix}"

        helper_list.push(new_helper_name.to_sym) unless helper_list.include?(new_helper_name.to_sym)

        helper_container.__send__(:define_method, new_helper_name) do |*args|
          locale_suffix         = I18n.locale.to_s.underscore
          default_locale_suffix = I18n.default_locale.to_s.underscore
          args_hash             = args.select {|arg| arg.is_a?(Hash) }.first
          args_locale_suffix    = args_hash[:locale].to_s.underscore if args_hash.present?

          if RouteTranslator.config.host_locales.present? && (args_hash.blank? || args_locale_suffix == default_locale_suffix)
            __send__("#{old_name}_native_#{default_locale_suffix}_#{suffix}", *args)
          elsif RouteTranslator.config.host_locales.present? && args_locale_suffix.present?
            __send__("#{old_name}_#{args_locale_suffix}_#{suffix}", *args)
          elsif respond_to?("#{old_name}_#{locale_suffix}_#{suffix}")
            __send__("#{old_name}_#{locale_suffix}_#{suffix}", *args)
          else
            __send__("#{old_name}_#{I18n.default_locale.to_s.underscore}_#{suffix}", *args)
          end
        end
      end
    end

    def self.translations_for(app, conditions, requirements, defaults, route_name, anchor, route_set, &block)
      add_untranslated_helpers_to_controllers_and_views(route_name, route_set.named_routes.module, route_set.named_routes.helpers)

      available_locales.each do |locale|
        new_conditions = conditions.dup
        new_conditions[:path_info] = translate_path(conditions[:path_info], locale)
        if new_conditions[:required_defaults] && !new_conditions[:required_defaults].include?(RouteTranslator.locale_param_key)
          new_conditions[:required_defaults] << RouteTranslator.locale_param_key if new_conditions[:required_defaults]
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
      available_locales = I18n.available_locales.dup
      available_locales.push *RouteTranslator.native_locales if RouteTranslator.native_locales.present?
      # Make sure the default locale is translated in last place to avoid
      # problems with wildcards when default locale is omitted in paths. The
      # default routes will catch all paths like wildcard if it is translated first.
      available_locales.push(available_locales.delete(I18n.default_locale))
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
  end
end
