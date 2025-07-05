# frozen_string_literal: true

require 'action_dispatch'

module ActionDispatch
  module Routing
    class RouteSet
      # TODO: Remove when dropping Rails < 8.1 support
      class << self
        def route_keyword_args?
          return @route_keyword_args if defined?(@route_keyword_args)

          @route_keyword_args = ::ActionDispatch::Routing::Mapper::Mapping.method(:build).arity == 12
        end
      end

      def add_localized_route(mapping, name, anchor, scope, path, controller, default_action, to, via, formatted, options_constraints, internal, options_mapping)
        route = RouteTranslator::Route.new(self, path, name, options_constraints, options_mapping, mapping)

        RouteTranslator::Translator.translations_for(route) do |locale, translated_name, translated_path, translated_options_constraints, translated_options|
          translated_path_ast = ::ActionDispatch::Journey::Parser.parse(translated_path)
          translated_mapping  = translate_mapping(locale, self, translated_options, translated_path_ast, scope, controller, default_action, to, formatted, via, translated_options_constraints, anchor, internal)

          add_route translated_mapping, translated_name
        end

        if RouteTranslator.config.generate_unnamed_unlocalized_routes
          add_route mapping, nil
        elsif RouteTranslator.config.generate_unlocalized_routes
          add_route mapping, name
        end
      end

      private

      def translate_mapping(locale, route_set, translated_options, translated_path_ast, scope, controller, default_action, to, formatted, via, translated_options_constraints, anchor, internal)
        scope_params = {
          blocks:      (scope[:blocks] || []).dup,
          constraints: scope[:constraints] || {},
          defaults:    scope[:defaults] || {},
          module:      scope[:module],
          options:     scope[:options] ? scope[:options].merge(translated_options) : translated_options
        }

        if RouteTranslator.config.host_locales.present?
          scope_params[:blocks].push RouteTranslator::Host.lambdas_for_locale(locale)
        end

        # TODO: Remove `else` branch when dropping Rails < 8.1 support
        if self.class.route_keyword_args?
          ::ActionDispatch::Routing::Mapper::Mapping.build scope_params, route_set, translated_path_ast, controller, default_action, to, via, formatted, translated_options_constraints, anchor, internal, translated_options
        else
          ::ActionDispatch::Routing::Mapper::Mapping.build scope_params, route_set, translated_path_ast, controller, default_action, to, via, formatted, translated_options_constraints, anchor, translated_options
        end
      end
    end
  end
end
