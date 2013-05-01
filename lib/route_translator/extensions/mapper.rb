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

          mapping = Mapping.new(@set, @scope, path, options)
          app, conditions, requirements, defaults, as, anchor = mapping.to_route
          if @localized
            @set.add_localized_route(app, conditions, requirements, defaults, as, anchor)
          else
            @set.add_route(app, conditions, requirements, defaults, as, anchor)
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
