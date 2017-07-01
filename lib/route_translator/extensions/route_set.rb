# frozen_string_literal: true

require 'action_dispatch'

module ActionDispatch
  module Routing
    class RouteSet
      def add_localized_route(mapping, path_ast, name, anchor, scope, path, controller, default_action, to, via, formatted, options_constraints, options)
        route = RouteTranslator::Route.new(self, path, name, options_constraints, options, mapping)

        RouteTranslator::Translator.translations_for(route) do |locale, translated_name, translated_path, translated_options_constraints, translated_options|
          translated_path_ast = ::ActionDispatch::Journey::Parser.parse(translated_path)
          translated_mapping  = translate_mapping(locale, self, translated_options, translated_path_ast, scope, controller, default_action, to, formatted, via, translated_options_constraints, anchor)

          add_route_to_set translated_mapping, translated_path_ast, translated_name, anchor
        end

        if RouteTranslator.config.generate_unnamed_unlocalized_routes
          add_route_to_set mapping, path_ast, nil, anchor
        elsif RouteTranslator.config.generate_unlocalized_routes
          add_route_to_set mapping, path_ast, name, anchor
        end
      end

      private

      def translate_mapping(locale, route_set, translated_options, translated_path_ast, scope, controller, default_action, to, formatted, via, translated_options_constraints, anchor)
        options = scope[:options] ? scope[:options].merge(translated_options) : translated_options

        defaults          = (scope[:defaults] || {}).dup
        scope_constraints = scope[:constraints] || {}

        blocks = scope[:blocks] ? scope[:blocks].dup : []

        if RouteTranslator.config.host_locales.present?
          blocks.push RouteTranslator::Host.lambdas_for_locale(locale)
        end

        ::ActionDispatch::Routing::Mapper::Mapping.new(route_set, translated_path_ast, defaults, controller, default_action, scope[:module], to, formatted, scope_constraints, blocks, via, translated_options_constraints, anchor, options)
      end

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
