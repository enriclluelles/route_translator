require 'action_dispatch'

module ActionDispatch
  module Routing
    class RouteSet
      def add_localized_route(*args)
        RouteTranslator::Translator.translations_for(*args) do |*translated_args|
          add_route(*translated_args)
        end
      end
    end
  end
end
