# frozen_string_literal: true

require 'route_translator/translator/path/segment'

module RouteTranslator
  module Translator
    module Path
      class << self
        private

        def display_locale?(locale)
          !RouteTranslator.config.hide_locale && (!default_locale?(locale) || config_requires_locale?)
        end

        def config_requires_locale?
          config = RouteTranslator.config
          (config.force_locale || config.generate_unlocalized_routes || config.generate_unnamed_unlocalized_routes).present?
        end

        def default_locale?(locale)
          locale.to_sym == I18n.default_locale.to_sym
        end

        def locale_param_present?(path)
          path.split('/').include? ":#{RouteTranslator.locale_param_key}"
        end

        def locale_segment(locale)
          if RouteTranslator.config.locale_segment_proc
            locale_segment_proc = RouteTranslator.config.locale_segment_proc

            locale_segment_proc.to_proc.call(locale)
          else
            locale.to_s.downcase
          end
        end
      end

      module_function

      # Translates a path and adds the locale prefix.
      def translate(path, locale, scope)
        new_path = path.dup
        final_optional_segments = new_path.slice!(%r{(\([^\/]+\))$})
        translated_segments = new_path.split('/').map do |seg|
          seg.split('.').map { |phrase| Segment.translate(phrase, locale, scope) }.join('.')
        end
        translated_segments.reject!(&:empty?)

        if display_locale?(locale) && !locale_param_present?(new_path)
          translated_segments.unshift(locale_segment(locale))
        end

        joined_segments = translated_segments.join('/')

        "/#{joined_segments}#{final_optional_segments}".gsub(%r{\/\(\/}, '(/')
      end
    end
  end
end
