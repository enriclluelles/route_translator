require 'action_dispatch'

module ActionDispatch
  module Routing
    class RouteSet
      def add_localized_route(app, conditions = {}, requirements = {}, defaults = {}, as = nil, anchor = true)
        RouteTranslator::Translator.translations_for(app, conditions, requirements, defaults, as, anchor, self) do |*translated_args|
          add_route(*translated_args)
        end

        if RouteTranslator.config.generate_unnamed_unlocalized_routes
          add_route app, conditions, requirements, defaults, nil, anchor
        elsif RouteTranslator.config.generate_unlocalized_routes
          add_route app, conditions, requirements, defaults, as, anchor
        end
      end
    end
  end
end
