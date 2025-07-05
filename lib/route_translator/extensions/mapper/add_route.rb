# frozen_string_literal: true

module ActionDispatch
  module Routing
    class Mapper
      # rubocop:disable Lint/UnderscorePrefixedVariableName, Metrics/PerceivedComplexity
      def add_route(action, controller, as, options_action, _path, to, via, formatted, anchor, options_constraints, internal, options_mapping)
        return super unless @localized

        path = path_for_action(action, _path)
        raise ArgumentError, 'path is required' if path.blank?

        action = action.to_s

        default_action = options_action || @scope[:action]

        if %r{^[\w\-/]+$}.match?(action)
          default_action ||= action.tr('-', '_') unless action.include?('/')
        else
          action = nil
        end

        as   = name_for_action(as, action) if as
        path = Mapping.normalize_path URI::RFC2396_PARSER.escape(path), formatted
        ast  = Journey::Parser.parse path

        mapping = Mapping.build(@scope, @set, ast, controller, default_action, to, via, formatted, options_constraints, anchor, internal, options_mapping)
        @set.add_localized_route(mapping, as, anchor, @scope, path, controller, default_action, to, via, formatted, options_constraints, internal, options_mapping)
      end
      # rubocop:enable Lint/UnderscorePrefixedVariableName, Metrics/PerceivedComplexity
    end
  end
end
