# frozen_string_literal: true

require 'route_translator/translator/route_helpers'
require 'route_translator/translator/path'
require 'route_translator/route'

module RouteTranslator
  module Translator
    class << self
      private

      def available_locales
        locales = RouteTranslator.available_locales
        # Make sure the default locale is translated in last place to avoid
        # problems with wildcards when default locale is omitted in paths. The
        # default routes will catch all paths like wildcard if it is translated first.
        locales.delete I18n.default_locale
        locales.push I18n.default_locale
      end

      def locale_from_args(args)
        args_hash = args.detect { |arg| arg.is_a?(Hash) }
        args_hash[:locale] if RouteTranslator.config.host_locales.present? && args_hash
      end

      def translate_name(name, locale, named_routes_names)
        return if name.blank?

        translated_name = "#{name}_#{locale.to_s.underscore}"

        translated_name if named_routes_names.exclude?(translated_name.to_sym)
      end

      def translate_options(options, locale)
        translated_options = options.dup

        if translated_options.exclude?(RouteTranslator.locale_param_key)
          translated_options[RouteTranslator.locale_param_key] = locale.to_s
        end

        translated_options
      end

      def translate_options_constraints(options_constraints, locale)
        translated_options_constraints = options_constraints.dup

        if translated_options_constraints.respond_to?(:[]=)
          translated_options_constraints[RouteTranslator.locale_param_key] = locale.to_s
        end

        translated_options_constraints
      end

      def translate_path(path, locale, scope)
        RouteTranslator::Translator::Path.translate(path, locale, scope)
      rescue I18n::MissingTranslationData => e
        raise e unless RouteTranslator.config.disable_fallback
      end
    end

    module_function

    def translations_for(route)
      RouteTranslator::Translator::RouteHelpers.add route.name, route.route_set.named_routes

      available_locales.each do |locale|
        translated_path = translate_path(route.path, locale, route.scope)
        next unless translated_path

        translated_name                = translate_name(route.name, locale, route.route_set.named_routes.names)
        translated_options_constraints = translate_options_constraints(route.options_constraints, locale)
        translated_options             = translate_options(route.options, locale)

        yield locale, translated_name, translated_path, translated_options_constraints, translated_options
      end
    end

    def route_name_for(args, old_name, suffix, kaller)
      args_locale         = locale_from_args(args)
      current_locale_name = I18n.locale.to_s.underscore

      locale = if args_locale
                 args_locale.to_s.underscore
               elsif kaller.respond_to?("#{old_name}_#{current_locale_name}_#{suffix}")
                 current_locale_name
               else
                 I18n.default_locale.to_s.underscore
               end

      "#{old_name}_#{locale}_#{suffix}"
    end
  end
end
