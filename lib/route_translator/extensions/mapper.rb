# frozen_string_literal: true

require 'action_dispatch'

module ActionDispatch
  module Routing
    class Mapper
      def localized
        @localized = true
        yield
      ensure
        @localized = false
      end

      # rubocop:disable Lint/UnderscorePrefixedVariableName, Metrics/PerceivedComplexity
      def add_route(action, controller, options, _path, to, via, formatted, anchor, options_constraints) # :nodoc:
        return super unless @localized

        path = path_for_action(action, _path)
        raise ArgumentError, 'path is required' if path.blank?

        action = action.to_s

        default_action = options.delete(:action) || @scope[:action]

        if %r{^[\w\-\/]+$}.match?(action)
          default_action ||= action.tr('-', '_') unless action.include?('/')
        else
          action = nil
        end

        as = if options.fetch(:as, true)
               name_for_action(options.delete(:as), action)
             else
               options.delete(:as)
             end

        path = Mapping.normalize_path URI::DEFAULT_PARSER.escape(path), formatted
        ast = Journey::Parser.parse path

        mapping = Mapping.build(@scope, @set, ast, controller, default_action, to, via, formatted, options_constraints, anchor, options)
        @set.add_localized_route(mapping, as, anchor, @scope, path, controller, default_action, to, via, formatted, options_constraints, options)
      end
      # rubocop:enable Lint/UnderscorePrefixedVariableName, Metrics/PerceivedComplexity

      private

      def define_generate_prefix(app, name)
        return super unless @localized

        RouteTranslator.available_locales.each do |locale|
          super(app, "#{name}_#{locale.to_s.underscore}")
        end
      end
    end
  end
end
