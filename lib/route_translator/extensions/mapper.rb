# frozen_string_literal: true
require 'action_dispatch'

module ActionDispatch
  module Routing
    class Mapper
      def localized
        @localized = true
        yield
        @localized = false
      end

      # rubocop:disable Lint/UnderscorePrefixedVariableName
      def add_route(action, controller, options, _path, to, via, formatted, anchor, options_constraints) # :nodoc:
        return super unless @localized

        path = path_for_action(action, _path)
        raise ArgumentError, 'path is required' if path.blank?

        action = action.to_s

        default_action = options.delete(:action) || @scope[:action]

        if action =~ %r{^[\w\-\/]+$}
          default_action ||= action.tr('-', '_') unless action.include?('/')
        else
          action = nil
        end

        as = if !options.fetch(:as, true) # if it's set to nil or false
               options.delete(:as)
             else
               name_for_action(options.delete(:as), action)
             end

        path = Mapping.normalize_path URI.parser.escape(path), formatted
        ast = Journey::Parser.parse path

        mapping = Mapping.build(@scope, @set, ast, controller, default_action, to, via, formatted, options_constraints, anchor, options)

        @set.add_localized_route(mapping, ast, as, anchor, @scope, path, controller, default_action, to, via, formatted, options_constraints, options)
      end
      # rubocop:enable Lint/UnderscorePrefixedVariableName
    end
  end
end
