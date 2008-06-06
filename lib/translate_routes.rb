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

      private

        def self.translate_current_routes(dictionaries)

          # reset routes
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
        
            # process the old route:
            new_old_route = clone_with_deeply_copied_static_segments(old_route) # we need a fresh route to apply requirements

            translate_static_segments(new_old_route, default_dict)
            add_language_requirements(new_old_route, default_lang)
            add_language_segment(new_old_route, default_lang) if prefix_on_default_lang
            new_routes << new_old_route
              
            # if it's a named one we append the lang suffix and replace the old helper by a language-based call
            if old_name
  
              trans_named_routes["#{old_name}_#{default_lang}"] = new_old_route
              trans_named_routes[old_name] = new_old_route # keep the old name to use the helper on integration tests

              new_named_routes.merge! trans_named_routes

              ['path', 'url'].each do |suffix|
                new_helper_name = "#{old_name}_#{suffix}"
                def_new_helper = <<-DEF_NEW_HELPER
                  def #{new_helper_name}(*args)                      
                    if defined? @#{lang_param_key}
                      send("#{old_name}_\#{@#{lang_param_key}}_#{suffix}", *args)
                    else
                      send("#{old_name}_\#{@#{default_lang}}_#{suffix}", *args)
                    end
                  end
                DEF_NEW_HELPER
                
                [ActionController::Base, ActionView::Base].each { |d| d.module_eval(def_new_helper) }
                ActionController::Routing::Routes.named_routes.helpers << new_helper_name.to_sym
              end

            end                      
            
          end
          
          # apply all new routes
          Routes.routes = new_routes
          new_named_routes.each { |name, r| Routes.named_routes.add name, r }

        end

        def self.clone_with_deeply_copied_static_segments(route)
          copy = Route.new
          copy.segments = []
          route.segments.each do |s|
  
            if s.instance_of?(StaticSegment)
              new_segment = StaticSegment.new
              new_segment.value = s.value.dup
              new_segment.is_optional = s.is_optional
            else
              new_segment = s.dup # just reference the original
            end

            copy.segments << new_segment
          end
          copy.conditions  = route.conditions.dup
          copy.requirements = route.requirements.dup
          copy
        end

        def self.add_language_requirements(route, lang)
          route.requirements[lang_param_key] = lang
        end
        
        def self.add_language_segment(route, lang)
          
          # divider ('/')
          new_divider_segment = DividerSegment.new
          new_divider_segment.value = route.segments.first.value
          new_divider_segment.is_optional = false # la prueba
          
          # static ('es')
          new_static_segment = StaticSegment.new
          new_static_segment.value = lang
          new_static_segment.is_optional = false
          
          route.segments = [new_divider_segment, new_static_segment] + route.segments

        end


        def self.translate_static_segments(route, dictionary)
          route.segments.each do |segment|
            if segment.instance_of?(StaticSegment) && dictionary[segment.value]
              segment.value = dictionary[segment.value]
            end
          end
        end

        def self.translate_route(route, dictionaries, route_name = nil)
          new_routes = []
          new_named_routes = {}
  
          dictionaries.keys.each do |lang|

            copy = clone_with_deeply_copied_static_segments(route)
            add_language_segment(copy, lang)
            add_language_requirements(copy, lang)
            translate_static_segments copy, dictionaries[lang]
  
            new_routes << copy
            new_named_routes["#{route_name}_#{lang}".to_sym] = copy if route_name
          
          end
          [new_routes, new_named_routes]
        end
      
    end
    
  end
end

