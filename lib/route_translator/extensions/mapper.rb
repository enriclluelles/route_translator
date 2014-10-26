require 'action_dispatch'

module ActionDispatch
  module Routing
    class Mapper
      def localized
        @localized = true
        yield
        @localized = false
      end

      if instance_methods.map(&:to_s).include?('add_route')
        def add_route(action, options) # :nodoc:
          path = path_for_action(action, options.delete(:path))

          if action.to_s =~ /^[\w\/]+$/
            options[:action] ||= action unless action.to_s.include?("/")
          else
            action = nil
          end

          if !options.fetch(:as, true)
            options.delete(:as)
          else
            options[:as] = name_for_action(options[:as], action)
          end

          begin
            mapping = Mapping.new(@set, @scope, path, options)
          rescue ArgumentError => e
            mapping = Mapping.build(@scope, @set, URI.parser.escape(path), options.delete(:as), options)
          end

          if @localized
            @set.add_localized_route(*mapping.to_route)
          else
            @set.add_route(*mapping.to_route)
          end
        end
      else
        module Base
          def match(path, options=nil)
            mapping = Mapping.new(@set, @scope, path, options || {})
            app, conditions, requirements, defaults, as, anchor = mapping.to_route
            if @localized
              @set.add_localized_route(app, conditions, requirements, defaults, as, anchor)
            else
              @set.add_route(app, conditions, requirements, defaults, as, anchor)
            end
            self
          end
        end
      end
    end
  end
end
