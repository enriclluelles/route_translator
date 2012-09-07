module RouteTranslator
  module RouteSet
    module Translator
      # Translate a specific RouteSet, usually Rails.application.routes, but can
      # be a RouteSet of a gem, plugin/engine etc.
      def translate
        Rails.logger.info "Translating routes (default locale: #{default_locale})" if defined?(Rails) && defined?(Rails.logger)

        # save original routes and clear route set
        original_routes = routes.dup
        original_named_routes = named_routes.routes.dup  # Hash {:name => :route}

        routes_to_create = []
        original_routes.each do |original_route|
          if localized_routes && localized_routes.include?(original_route.to_s)
            translations_for(original_route).each do |translated_route_args|
              routes_to_create << translated_route_args
            end
          else
            route = untranslated_route original_route
            routes_to_create << route
          end
          # Always generate unlocalized routes?
          if RouteTranslator.config.generate_unlocalized_routes
            route = untranslated_route original_route
            routes_to_create << route
          end
        end

        reset!

        routes_to_create.each do |r|
          add_route(*r)
        end


        Hash[original_named_routes.select{|k,v| localized_routes && localized_routes.include?(v.to_s)}].each_key do |route_name|
          named_routes.helpers.concat add_untranslated_helpers_to_controllers_and_views(route_name)
        end

        finalize!
        named_routes.install
      end

      # Add standard route helpers for default locale e.g.
      #   I18n.locale = :de
      #   people_path -> people_de_path
      #   I18n.locale = :fr
      #   people_path -> people_fr_path
      def add_untranslated_helpers_to_controllers_and_views old_name
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

      # Generate translations for a single route for all available locales
      def translations_for route
        available_locales.map do |locale|
          translate_route(route, locale.dup) #we duplicate the locale string to ensure it's not frozen
        end
      end

      # Generate translation for a single route for one locale
      def translate_route route, locale
        path_regex = route.path.respond_to?(:spec) ? route.path.spec : route.path

        conditions = route.conditions.dup.merge({
          :path_info => translate_path(path_regex.dup.to_s, locale)
        })

        conditions[:request_method] = request_method_array(conditions[:request_method]) if conditions[:request_method]

        requirements = route.requirements.dup.merge!(LOCALE_PARAM_KEY => locale)
        defaults = route.defaults.dup.merge LOCALE_PARAM_KEY => locale

        new_name = "#{route.name}_#{locale_suffix(locale)}" if route.name

        [route.app, conditions, requirements, defaults, new_name]
      end

      def untranslated_route route
        path_regex = route.path.respond_to?(:spec) ? route.path.spec : route.path

        conditions = route.conditions.dup.merge({
          :path_info => path_regex.to_s
        })

        conditions[:request_method] = request_method_array(conditions[:request_method]) if conditions[:request_method]

        [route.app, conditions, route.requirements.dup, route.defaults.dup, route.name]
      end

      def request_method_array(reg)
        reg.source.gsub(%r{\^|\$}, "").split("|")
      end

      # Translates a path and adds the locale prefix.
      def translate_path(path, locale)
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
      def translate_path_segment segment, locale
        return segment if segment.blank? or segment.starts_with?(":")

        match = TRANSLATABLE_SEGMENT.match(segment)[1] rescue nil

        (translate_string(match, locale) || segment)
      end

      def translate_string(str, locale)
        @dictionary[locale.to_s][str.to_s]
      end

      private

      def reset!
        clear!
        named_routes.module.instance_methods.each do |method|
          named_routes.module.send(:remove_method, method)
        end
      end
    end
  end
end
