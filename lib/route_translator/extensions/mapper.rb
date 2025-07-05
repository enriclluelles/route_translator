# frozen_string_literal: true

require 'action_dispatch'

# TODO: Remove `else` branch when dropping Rails < 8.1 support
if ActionDispatch::Routing::Mapper.instance_method(:add_route).arity == 12
  require_relative 'mapper/add_route'
else
  require_relative 'mapper/add_route_legacy'
end

module ActionDispatch
  module Routing
    class Mapper
      def localized
        @localized = true
        yield
      ensure
        @localized = false
      end

      private

      def define_generate_prefix(app, name)
        return super unless @localized

        RouteTranslator::Translator.available_locales.each do |locale|
          super(app, "#{name}_#{locale.to_s.underscore}")
        end
      end
    end
  end
end
