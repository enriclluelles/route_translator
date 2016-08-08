# frozen_string_literal: true

require File.expand_path('../translator/route_helpers', __FILE__)
require File.expand_path('../translator/path', __FILE__)
require File.expand_path('../route', __FILE__)

module RouteTranslator
  module Translator
    class << self
      private

      def translated_attributes(locale, translated_path, route)
        translated_options_constraints = route.options_constraints.dup
        translated_options             = route.options.dup

        translated_options_constraints[RouteTranslator.locale_param_key] = locale.to_s
        translated_options[RouteTranslator.locale_param_key]             = locale.to_s.gsub('native_', '') unless translated_options.include?(RouteTranslator.locale_param_key)

        translated_name = translate_name(route.name, locale, route.route_set.named_routes.names)

        [translated_name, translated_path, translated_options_constraints, translated_options]
      end

      def available_locales
        locales = RouteTranslator.available_locales
        locales.concat(RouteTranslator.native_locales) if RouteTranslator.native_locales.present?
        # Make sure the default locale is translated in last place to avoid
        # problems with wildcards when default locale is omitted in paths. The
        # default routes will catch all paths like wildcard if it is translated first.
        locales.delete I18n.default_locale
        locales.push I18n.default_locale
      end

      def host_locales_option?
        RouteTranslator.config.host_locales.present?
      end

      def translate_name(name, locale, named_routes_names)
        return unless name.present?
        translated_name = "#{name}_#{locale.to_s.underscore}"
        if named_routes_names.include?(translated_name.to_sym)
          nil
        else
          translated_name
        end
      end
    end

    module_function

    def translations_for(route)
      RouteTranslator::Translator::RouteHelpers.add route.name, route.route_set.named_routes

      available_locales.each do |locale|
        begin
          translated_path = RouteTranslator::Translator::Path.translate(route.path, locale, route.scope)
        rescue I18n::MissingTranslationData => e
          raise e unless RouteTranslator.config.disable_fallback
          next
        end

        yield translated_attributes(locale, translated_path, route)
      end
    end

    def route_name_for(args, old_name, suffix, kaller)
      args_hash           = args.detect { |arg| arg.is_a?(Hash) }
      args_locale         = host_locales_option? && args_hash && args_hash[:locale]
      current_locale_name = I18n.locale.to_s.underscore

      locale = if args_locale
                 args_locale.to_s.underscore
               elsif kaller.respond_to?("#{old_name}_native_#{current_locale_name}_#{suffix}")
                 "native_#{current_locale_name}"
               elsif kaller.respond_to?("#{old_name}_#{current_locale_name}_#{suffix}")
                 current_locale_name
               else
                 I18n.default_locale.to_s.underscore
               end

      "#{old_name}_#{locale}_#{suffix}"
    end
  end
end
