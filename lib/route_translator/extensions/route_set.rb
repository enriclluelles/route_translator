require 'action_dispatch'

module ActionDispatch
  module Routing
    class RouteSet
      def add_localized_route(app, conditions = {}, requirements = {}, defaults = {}, as = nil, anchor = true)
        RouteTranslator::Translator.translations_for(app, conditions, requirements, defaults, as, anchor, self) do |*translated_args|
          add_route(*translated_args)
        end
      end
    end
  end
end