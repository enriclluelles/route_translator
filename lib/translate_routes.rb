# Author: Raul Murciano [http://raul.murciano.net] for Domestika [http://domestika.org]
# Copyright (c) 2007, Released under the MIT license (see MIT-LICENSE)

module ActionDispatch

  module Routing

    module Translator
      
      mattr_accessor :options
      @@options
      
      mattr_accessor :prefix
      @@prefix
      
      mattr_accessor :default_locale
      @@default_locale
      
      mattr_accessor :prefix_on_default_locale
      @@prefix_on_default_locale

      mattr_accessor :locale_param_key
      @@locale_param_key = :locale  # set to :locale for params[:locale]

      mattr_accessor :original_routes, :original_named_routes, :original_names, :dictionaries

      def self.translate
        init_dictionaries
        yield @@dictionaries
        @using_i18n = false
        Translator.translate_current_routes
      end

      def self.translate_from_file(file_path, options = {})
        @@prefix = options[:prefix] || true
        @@prefix_on_default_locale = options[:prefix_on_default_locale] || false
        @@default_locale = options[:default_locale] || I18n.default_locale
        init_dictionaries
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

        def self.init_dictionaries
          @@dictionaries = { default_locale => {} }
        end

        def self.available_locales
          @@dictionaries.keys.map(&:to_s).uniq
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
          Rails.logger.info "Translating routes (default locale: #{default_locale})" if defined?(Rails.logger)
          
          @@original_routes = Rails.application.routes.routes.dup                     # Array [routeA, routeB, ...]
          @@original_named_routes = Rails.application.routes.named_routes.routes.dup  # Hash {:name => :route}
          
          Rails.application.routes.clear!
          clear_helper_methods
          new_routes = []

          @@original_routes.each do |old_route|
            trans_routes = translate_route old_route
            trans_routes.each do |trans_route_args|
              Rails.application.routes.add_route *trans_route_args
            end  
          end
          
          @@original_named_routes.each { |old_name, old_route| add_untranslated_helpers_to_controllers_and_views( old_name ) }
        end
        
        def self.clear_helper_methods
          ## HACK for bug in rails
          mod = Rails.application.routes.named_routes.module
          mod.instance_methods.each do |method|
            mod.send :remove_method, method
          end
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
            [ActionController::Base, ActionView::Base, ActionMailer::Base, ActionDispatch::Routing::UrlFor].each { |d| d.module_eval(def_new_helper) }
            Rails.application.routes.named_routes.helpers << new_helper_name.to_sym
          end
        end

        def self.locale_requirements(orig, locale)
          orig.requirements.merge(@@locale_param_key => locale)
        end
        
        def self.translate_path_part path, locale
          if path.blank? or path.starts_with? ":"
            path
          else
            path.match /^(\w+)\(?/
            @@dictionaries[locale][$1] || path
          end
        end
        
        def self.locale_path(orig, locale)
          segments = []
          orig.path.split('/').each do |path_part|
            segments << translate_path_part(path_part, locale)
          end
          path = segments.join("/")
          if prefix and (!default_locale?(locale) or prefix_on_default_locale)
            path = "/:#{@@locale_param_key}#{path}"
          end
          path = "/" if path.blank?
          path
        end

        def self.translate_route_by_locale(orig, locale, orig_name=nil)
          requirements = locale_requirements(orig, locale)
          conditions = {:path_info => locale_path(orig, locale)}
          conditions[:request_method] = orig.conditions[:request_method].source.upcase if orig.conditions[:request_method]
          defaults = orig.defaults.merge(@@locale_param_key => locale)
          new_name = "#{orig_name}_#{locale_suffix(locale)}" if orig_name
          [orig.app, conditions, requirements, defaults, new_name, {}]
        end

        def self.root_route?(route)
          route.segments.length == 1
        end

        def self.translate_route(route)
          new_routes = []
          available_locales.each do |locale|
            new_routes << translate_route_by_locale(route, locale, route.name)
          end
          new_routes
        end
        
        def self.default_locale? locale
          default_locale.to_s == locale.to_s
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
[ActionController::Base, ActionView::Base, ActionMailer::Base, ActionDispatch::Routing::UrlFor].map do |klass|
  klass.class_eval do
    private
      def locale_suffix(locale)
        # use ActionDispatch in Rails 3
        eval ActionDispatch::Routing::Translator.locale_suffix_code
      end
  end
end
