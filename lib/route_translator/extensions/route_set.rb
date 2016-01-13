require 'action_dispatch'

module ActionDispatch
  module Routing
    class RouteSet
      def add_localized_route(mapping, path_ast, name, anchor, scope, path, controller, default_action, to, via, formatted, options_constraints, options)
        RouteTranslator::Translator.translations_for(self, path, name, options) do |translated_name, translated_path, translated_options|
          translated_path_ast = ::ActionDispatch::Journey::Parser.parse(translated_path)
          translated_mapping  = ::ActionDispatch::Routing::Mapper::Mapping.build(scope, self, translated_path_ast, controller, default_action, to, via, formatted, options_constraints, anchor, translated_options)

          add_route translated_mapping, translated_path_ast, translated_name, anchor
        end

        if RouteTranslator.config.generate_unnamed_unlocalized_routes
          add_route mapping, path_ast, nil, anchor
        elsif RouteTranslator.config.generate_unlocalized_routes
          add_route mapping, path_ast, name, anchor
        end
      end
    end
  end
end
