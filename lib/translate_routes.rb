# Author: Raul Murciano [http://raul.murciano.net] for Domestika [http://domestika.org]
# Copyright (c) 2007, Released under the MIT license (see MIT-LICENSE)

module ActionDispatch

  module Routing

    module Translator

      mattr_accessor :translation_scope
      @@translation_scope = ""

      mattr_accessor :prefix
      @@prefix = true

      mattr_accessor :prefix_on_default_locale
      @@prefix_on_default_locale = false

      mattr_accessor :locale_param_key
      @@locale_param_key = :locale  # set to :locale for params[:locale]

      # rudionrails
      mattr_accessor :ignore_routes # regex for/or route symbols that should not be translated
      @@ignore_routes = []

      mattr_accessor :ignore_route_segments # regex for urls that should not be translated
      @@ignore_route_segments = []
      # end: rudionrails

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
        file_path =  File.join(Rails.root, path)
        yaml = YAML.load_file(file_path)
        # yaml.each_pair{ |k,v| @@dictionaries[k.to_s] = v || {} }  
        yaml.each_pair{ |k,v| @@dictionaries[k.to_s] = (v|| {})['routes'] || {} }        
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
          (@@original_routes || RouteSet.routes).each do |r|
            # now has segment_keys method
            r.segment_keys do |key|                       
              static_segments << key.to_s
            end
          end
          static_segments.uniq.sort
        end

        def self.ignore?( route )
          original_name = @@original_named_routes.index( route )
            # now has segment_keys method          
          ignore_route?( original_name ) || ignore_segments?( route.segment_keys )
        end

        def self.ignore_route?(name)
          return false if name.nil?
          ignore_routes.each do |filter|
            case filter
              when Regexp:
                return true if name.to_s =~ filter
              when String:
                return true if name.to_s == filter
              when Symbol:
                return true if name == filter
            end
          end          
          false
        end

        def self.ignore_segments?( segment_keys )
          return false if segment_keys.nil? || segment_keys.empty?
          
          segment = segment_keys.join(" ")
          ignore_route_segments.each do |filter|
            case filter
              when Regexp then return true if segment =~ filter
              when String then return true if segment == filter
              when Symbol then return true if segment.to_sym == filter
            end
          end
          false
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

          # rails 3 default logger
          Rails.logger.info "Translating routes (default locale: #{default_locale})" defined?(Rails.logger)
          
          @@original_routes = RouteSet.routes.dup                     # Array [routeA, routeB, ...]
          @@original_named_routes = RouteSet.named_routes.routes.dup  # Hash {:name => :route}
          @@original_names = @@original_named_routes.keys
          
          
          RouteSet.clear!
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

          RouteSet.routes = new_routes
          new_named_routes.merge(@@original_named_routes).each { |name, r| RouteSet.named_routes.add name, r }
          
          @@original_named_routes.each { |old_name, old_route| add_untranslated_helpers_to_controllers_and_views( old_name ) unless ignore?( old_route ) }
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

            # use ActionDispatch in Rails 3
            # use RouteSet, named_routes has :routes and :helpers 
            [ActionController::Base, ActionView::Base, ActionMailer::Base, ActionController::UrlWriter].each { |d| d.module_eval(def_new_helper) }
            ActionDispatch::Routing::RouteSet.named_routes.helpers << new_helper_name.to_sym
          end
        end

        def self.add_prefix?(lang)
          @@prefix && (@@prefix_on_default_locale || lang != default_locale)
        end
                                      
        # assumes segment has been converted to string 
        # I18n.translate(locale, key, options = {})
        def self.translate_segment_key(segment, locale)
          if @using_i18n
            # tmp = I18n.locale
            value = I18n.translate locale, segment, {:default => segment.dup, :scope => @@translation_scope}
            # I18n.locale = tmp
          else
            value = @@dictionaries[locale][segment] || segment.dup
          end
          value
        end

        # in rails 3, static segments are just keys/strings!
        # we should also handle optional segments: “/:controller(/:action(/:id))(.:format)” 
        # def segment_keys
        #   @segment_keys ||= conditions[:path_info].names.compact.map { |key| key.to_sym }
        # end 
        # class NamedRouteCollection
        # :routes               
        # def names
        #   routes.keys
        # end        
        
        def self.locale_segments(orig, locale)
          segments = []
          
          if add_prefix?(locale) # initial prefix i.e: /en-US
            segments << "#{locale}_#{orig}"
          end

          # use segment keys
          orig.segment_keys.each do |s|               
            # convert segment symbol to string
            new_segment = translate_segment_key(s.to_s, locale)
            segments << new_segment
          end
          # should segments be joined like this!? or with a / ?
          segments.join("/")
        end

        def self.locale_requirements(orig, locale)
          orig.requirements.merge(@@locale_param_key => locale)
        end

        def self.translate_route_by_locale(orig, locale, orig_name=nil)
          segments = locale_segments(orig, locale)
          requirements = locale_requirements(orig, locale)
          conditions = orig.conditions

          Route.new(Rails.application, conditions, requirements, segments).freeze
        end

        def self.root_route?(route)
          route.segments.length == 1
        end

        def self.translate_route(route, route_name = nil)
          new_routes = []
          new_named_routes = {}

          available_locales.each do |locale|
            translated = translate_route_by_locale(route, locale, route_name)
            new_routes << translated          
            locale_suffix = locale_suffix(locale)
            new_named_routes["#{route_name}_#{locale_suffix}".to_sym] = translated if route_name
          end

          # add original route "as is" in addition to the translated versions
          new_routes << route
          new_named_routes[route_name.to_sym] = route if route_name

          [new_routes, new_named_routes]
        end
      
    end
    
  end
end

# Add set_locale_from_url to controllers
# also works in Rails 3
ActionController::Base.class_eval do 
  private
    # called by before_filter
    def set_locale_from_url            
      # use ActionDispatch in Rails 3
      I18n.locale = params[ActionDispatch::Routing::Translator.locale_param_key]
      default_url_options({ActionDispatch::Routing::Translator => I18n.locale })
    end
end

# Add locale_suffix to controllers, views and mailers   
# also works in Rails 3
[ActionController::Base, ActionView::Base, ActionMailer::Base, ActionController::UrlWriter].map do |klass|
  klass.class_eval do
    private
      def locale_suffix(locale)
        # use ActionDispatch in Rails 3
        eval ActionDispatch::Routing::Translator.locale_suffix_code
      end
  end
end
