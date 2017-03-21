# frozen_string_literal: true
require 'action_dispatch'

module ActionDispatch
  module Routing
    class RouteSet
      def add_localized_route(mapping, path_ast, name, anchor, scope, path, controller, default_action, to, via, formatted, options_constraints, options)
        route = RouteTranslator::Route.new(self, path, name, options_constraints, options, mapping)

        RouteTranslator::Translator.translations_for(route) do |translated_name, translated_path, translated_options_constraints, translated_options|
          translated_path_ast = ::ActionDispatch::Journey::Parser.parse(translated_path)
          translated_mapping  = ::ActionDispatch::Routing::Mapper::Mapping.build(scope, self, translated_path_ast, controller, default_action, to, via, formatted, translated_options_constraints, anchor, translated_options)

          add_route_to_set translated_mapping, translated_path_ast, translated_name, anchor
        end

        if RouteTranslator.config.generate_unnamed_unlocalized_routes
          add_route_to_set mapping, path_ast, nil, anchor
        elsif RouteTranslator.config.generate_unlocalized_routes
          add_route_to_set mapping, path_ast, name, anchor
        end
      end

      private

      def add_route_to_set(mapping, path_ast, name, anchor)
        if method(:add_route).arity == 4
          add_route mapping, path_ast, name, anchor
        else
          add_route mapping, name
        end
      end
    end
  end
end
