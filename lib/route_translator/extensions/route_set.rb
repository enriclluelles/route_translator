require 'action_dispatch'

module ActionDispatch
  module Routing
    class RouteSet
      def add_localized_route(app, conditions = {}, requirements = {}, defaults = {}, name = nil, anchor = true)
        path_info = conditions[:path_info]

        RouteTranslator::Translator.translations_for(path_info) do |pi|
          cd = conditions.dup
          cd[:path_info] = pi
          add_route(app, cd, requirements, defaults, name, anchor)
        end
      end
    end
  end
end
