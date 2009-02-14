# Author: Raul Murciano [http://raul.murciano.net] for Domestika [http://domestika.org]
# Copyright (c) 2007, Released under the MIT license (see MIT-LICENSE)

module ActionController

  module Routing

    module Translator
      
      mattr_accessor :prefix_on_default_locale
      @@prefix_on_default_locale = false

      mattr_accessor :locale_param_key
      @@locale_param_key = :locale  # set to :locale for params[:locale]

      mattr_accessor :original_routes, :original_named_routes, :original_names, :dictionaries

      def self.translate
        init_dictionaries
        yield @@dictionaries
        @using_i18n = false
        Translator.translate_current_routes
      end

      def self.translate_from_file(*path)
        init_dictionaries
        path = %w(locales routes.yml) if path.blank?
        file_path =  File.join(RAILS_ROOT, path)
        yaml = YAML.load_file(file_path)
        yaml.each_pair{ |k,v| @@dictionaries[k.to_s] = v || {} }
        @using_i18n = false
        Translator.translate_current_routes
      end

      def self.i18n(*locales)
        init_dictionaries
        locales = I18n.available_locales if locales.blank? && I18n.respond_to?(:available_locales)
        locales.each{ |locale| @@dictionaries[locale] = {} }
        @using_i18n = true
        Translator.translate_current_routes
      end
      
      private

        def self.default_locale
          I18n.default_locale.to_s
        end

        def self.init_dictionaries
          @@dictionaries = { default_locale => {} }
        end

        def self.available_locales
          @@dictionaries.keys.map(&:to_s).uniq
        end

        def self.original_static_segments
          static_segments = []
          (@@original_routes || Routes.routes).each do |r|
            r.segments.select do |s| 
              static_segments << s.value if s.instance_of?(ActionController::Routing::StaticSegment)
            end
          end
          static_segments.uniq.sort
        end

        # code shared by translation and application helpers,
        # it generates a suffix code for a given locale: en-US -> en_us
        def self.locale_suffix_code
          'locale.to_s.underscore'
        end

        class_eval <<-FOO
           def self.locale_suffix(locale)
             #{self.locale_suffix_code}
           end
        FOO
        def self.translate_current_routes
          
          RAILS_DEFAULT_LOGGER.info "Translating routes (default locale: #{default_locale})" if defined? RAILS_DEFAULT_LOGGER
          
          @@original_routes = Routes.routes.dup                     # Array [routeA, routeB, ...]
          @@original_named_routes = Routes.named_routes.routes.dup  # Hash {:name => :route}
          @@original_names = @@original_named_routes.keys
          
          Routes.clear!
          new_routes = []
          new_named_routes = {}

          @@original_routes.each do |old_route|

            old_name = @@original_named_routes.index(old_route)
            # process and add the translated ones
            trans_routes, trans_named_routes = translate_route(old_route, old_name)

            if old_name
              new_named_routes.merge! trans_named_routes
            end

            new_routes.concat(trans_routes)
          
          end
        
          Routes.routes = new_routes
          new_named_routes.each { |name, r| Routes.named_routes.add name, r }
          
          @@original_names.each{ |old_name| add_untranslated_helpers_to_controllers_and_views(old_name) }
        end

        # The untranslated helper (root_path instead root_en_path) redirects according to the current locale
        def self.add_untranslated_helpers_to_controllers_and_views(old_name)
          
          ['path', 'url'].each do |suffix|
            new_helper_name = "#{old_name}_#{suffix}"
            def_new_helper = <<-DEF_NEW_HELPER
              def #{new_helper_name}(*args)
                send("#{old_name}_\#{locale_suffix(I18n.locale)}_#{suffix}", *args)
              end
            DEF_NEW_HELPER

            [ActionController::Base, ActionView::Base, ActionMailer::Base].each { |d| d.module_eval(def_new_helper) }
            ActionController::Routing::Routes.named_routes.helpers << new_helper_name.to_sym
          end
        end

        def self.add_prefix?(lang)
          @@prefix_on_default_locale || lang != default_locale
        end

        def self.translate_static_segment(segment, locale)
          if @using_i18n
            tmp = I18n.locale
            I18n.locale = locale
            value = I18n.t segment.value, :default => segment.value.dup
            I18n.locale = tmp
          else
            value = @@dictionaries[locale][segment.value] || segment.value.dup
          end
          StaticSegment.new(value, :raw => segment.raw, :optional => segment.optional?)
        end

        def self.locale_segments(orig, locale)
          segments = []
          
          if add_prefix?(locale) # initial prefix i.e: /en-US
            divider = DividerSegment.new(orig.segments.first.value, :optional => false) # divider ('/')
            static = StaticSegment.new(locale, :optional => false) # static ('en-US')
            segments += [divider, static]
          end
          
          orig.segments.each do |s|
            if s.instance_of?(StaticSegment)
              new_segment = translate_static_segment(s, locale)
            else
              new_segment = s.dup # just reference the original
            end
            segments << new_segment
          end
          segments
        end

        def self.locale_requirements(orig, locale)
          orig.requirements.merge(@@locale_param_key => locale)
        end

        def self.translate_route_by_locale(orig, locale, orig_name=nil)
          segments = locale_segments(orig, locale)
          requirements = locale_requirements(orig, locale)
          conditions = orig.conditions
          
          Route.new(segments, requirements, conditions).freeze
        end

        def self.root_route?(route)
          route.segments.length == 1
        end

        def self.translate_route(route, route_name = nil)
          new_routes = []
          new_named_routes = {}
          
          if root_route?(route) && prefix_on_default_locale
            # add the root route "as is" in addition to the translated versions
            new_routes << route
            new_named_routes[route_name] = route
          end

          available_locales.each do |locale|
            translated = translate_route_by_locale(route, locale, route_name)
            new_routes << translated          
            locale_suffix = locale_suffix(locale)
            new_named_routes["#{route_name}_#{locale_suffix}".to_sym] = translated if route_name
          end
          [new_routes, new_named_routes]
        end
      
    end
    
  end
end

# Add set_locale_from_url to controllers
ActionController::Base.class_eval do 
  private
    def set_locale_from_url
      I18n.locale = params[ActionController::Routing::Translator.locale_param_key]
      default_url_options({ActionController::Routing::Translator => I18n.locale })
    end
end

# Add locale_suffix to controllers, views and mailers
[ActionController::Base, ActionView::Base, ActionMailer::Base].map do |klass|
  klass.class_eval do
    private
      def locale_suffix(locale)
        eval ActionController::Routing::Translator.locale_suffix_code
      end
  end
end
