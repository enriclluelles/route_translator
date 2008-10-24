require 'ruby-debug'

# TranslateRoutes

module ActionController

  module Routing

    module Translator
      
      mattr_accessor :default_lang
      @@default_lang = 'en'

      mattr_accessor :prefix_on_default_lang
      @@prefix_on_default_lang = false

      mattr_accessor :lang_param_key
      @@lang_param_key = :lang        # e.g: :lang generates params[:lang] and @lang controller variable

      mattr_accessor :original_routes

      def self.translate
        dictionaries = Hash.new
        yield dictionaries    
        Translator.translate_current_routes dictionaries
      end


      def self.translate_from_files
        files_prefix = 'routes_'
        dictionaries = Hash.new
        files =  Dir[File.join(RAILS_ROOT, 'config', "#{files_prefix}*.{yml,yaml}")]
        files.each do |file| 
          key = File.basename(file, '.*').gsub(files_prefix,'')
          dictionaries[key] = YAML.load_file(file) || {}
        end
        dictionaries[default_lang] = {} unless dictionaries.has_key?(default_lang)
        Translator.translate_current_routes dictionaries
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

      private

        def self.translate_current_routes(dictionaries)

          # reset routes
          @@original_routes ||= Routes.routes.dup
          old_routes = Routes.routes.dup # Array [routeA, routeB, ...]
          old_names = Routes.named_routes.routes.dup # Hash {:name => :route}    
          Routes.clear!
          new_routes = []
          new_named_routes = {}

          # take apart the default_lang dictionary if present
          default_dict = dictionaries.has_key?(default_lang) ? dictionaries.delete(default_lang) : {}

          old_routes.each do |old_route|

            old_name = old_names.index(old_route)
            # process and add the translated ones
            trans_routes, trans_named_routes = translate_route(old_route, dictionaries, old_name)
            new_routes.concat(trans_routes)
      
            # translate and add the old route:
            new_old_route = translate_route_by_lang(old_route, default_lang, default_dict, old_name)

            new_routes << new_old_route
            
            # if it's a named one we append the lang suffix and replace the old helper by a language-based call
            if old_name
              trans_named_routes["#{old_name}_#{default_lang}"] = new_old_route
              trans_named_routes[old_name] = new_old_route # keep the old name to use the helper on integration tests
              new_named_routes.merge! trans_named_routes
              generate_helpers(old_name)
            end
          
          end
        
          # apply all new routes
          Routes.routes = new_routes
          new_named_routes.each { |name, r| Routes.named_routes.add name, r }
          
        end

        def self.generate_helpers(old_name)
          ['path', 'url'].each do |suffix|
            new_helper_name = "#{old_name}_#{suffix}"
            def_new_helper = <<-DEF_NEW_HELPER
              def #{new_helper_name}(*args)                      
                if defined? @#{lang_param_key}
                  send("#{old_name}_\#{@#{lang_param_key}}_#{suffix}", *args)
                else
                  send("#{old_name}_#{default_lang}_#{suffix}", *args)
                end
              end
            DEF_NEW_HELPER

            [ActionController::Base, ActionView::Base].each { |d| d.module_eval(def_new_helper) }
            ActionController::Routing::Routes.named_routes.helpers << new_helper_name.to_sym
          end
        end

        def self.add_prefix?(lang)
          @@prefix_on_default_lang || lang != @@default_lang
        end

        def self.translate_static_segments(route, dictionary)
          segments = []
          route.segments.each do |s|
            if s.instance_of?(StaticSegment)
              new_segment = StaticSegment.new
              new_segment.value = dictionary[s.value] || s.value.dup
              new_segment.is_optional = s.is_optional
            else
              new_segment = s.dup # just reference the original
            end
            segments << new_segment
          end
          segments
        end
        
        def self.lang_segments(orig, lang, dictionary)
          return translate_static_segments(orig, dictionary) unless add_prefix?(lang)

          # divider ('/')
          divider = DividerSegment.new
          divider.value = orig.segments.first.value
          divider.is_optional = false # la prueba
          
          # static ('es')
          static = StaticSegment.new
          static.value = lang
          static.is_optional = false
          
          [divider, static] + translate_static_segments(orig, dictionary)
        end

        def self.lang_requirements(orig, lang)
          orig.requirements.merge(@@lang_param_key => lang)
        end

        def self.translate_route_by_lang(orig, lang, dictionary, orig_name=nil)
          segments = lang_segments(orig, lang, dictionary)
          requirements = lang_requirements(orig, lang)
          conditions = orig.conditions
          
          r = Route.new
          r.segments = segments
          r.requirements = requirements
          r.conditions = conditions
          r
        end

        def self.translate_route(route, dictionaries, route_name = nil)
          new_routes = []
          new_named_routes = {}
  
          dictionaries.keys.each do |lang|
            translated = translate_route_by_lang(route, lang, dictionaries[lang], route_name)  
            new_routes << translated
            new_named_routes["#{route_name}_#{lang}".to_sym] = translated if route_name
          end
          [new_routes, new_named_routes]
        end
      
    end
    
  end
end

