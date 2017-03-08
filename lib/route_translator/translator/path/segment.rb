# frozen_string_literal: true
module RouteTranslator
  module Translator
    module Path
      module Segment
        class << self
          private

          def fallback_options(str, locale)
            if RouteTranslator.config.disable_fallback && locale.to_s != I18n.default_locale.to_s
              { scope: :routes, fallback: true }
            else
              { scope: :routes, default: str }
            end
          end

          def translate_resource(str, locale, opts)
            handler = proc { |exception| exception }

            if I18n.translate(str, opts.merge(exception_handler: handler)).is_a?(I18n::MissingTranslation)
              I18n.translate(str, opts.merge(fallback_options(str, locale)))
            else
              I18n.translate(str, opts)
            end
          end

          def translate_string(str, locale, scope)
            locale = locale.to_s.gsub('native_', '')
            translated_resource = translate_resource(str, locale, scope: scope, locale: locale)

            URI.escape translated_resource
          end
        end

        module_function

        # Translates a single path segment.
        #
        # If the path segment contains something like an optional format
        # "people(.:format)", only "people" will be translated.
        # If there is no translation, the path segment is blank, begins with a
        # ":" (param key) or "*" (wildcard), the segment is returned untouched.
        def translate(segment, locale, scope)
          return segment if segment.empty?
          named_param, hyphenized = segment.split('-'.freeze, 2) if segment.starts_with?(':'.freeze)
          return "#{named_param}-#{translate(hyphenized.dup, locale, scope)}" if hyphenized
          return segment if segment.starts_with?('('.freeze) || segment.starts_with?('*'.freeze) || segment.include?(':'.freeze)

          appended_part = segment.slice!(/(\()$/)
          match = TRANSLATABLE_SEGMENT.match(segment)[1] if TRANSLATABLE_SEGMENT.match(segment)

          (translate_string(match, locale, scope) || segment) + appended_part.to_s
        end
      end
    end
  end
end
