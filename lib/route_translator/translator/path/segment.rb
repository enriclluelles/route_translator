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

          def translatable_segment(segment)
            matches = TRANSLATABLE_SEGMENT.match(segment)
            matches[1] if matches.present?
          end

          def translate_resource(str, locale, scope)
            handler = proc { |exception| exception }
            opts    = { locale: locale, scope: scope }

            if I18n.translate(str, opts.merge(exception_handler: handler)).is_a?(I18n::MissingTranslation)
              I18n.translate(str, opts.merge(fallback_options(str, locale)))
            else
              I18n.translate(str, opts)
            end
          end

          def translate_string(str, locale, scope)
            sanitized_locale = RouteTranslator::LocaleSanitizer.sanitize(locale)
            translated_resource = translate_resource(str, sanitized_locale, scope)

            # restore URI.escape behaviour to avoid breaking change
            CGI.escape(translated_resource).gsub('%2F', '/')
          end
        end

        module_function

        # Translates a single path segment.
        #
        # If the path segment contains something like an optional format
        # "people(.:format)", only "people" will be translated.
        # If the path contains a hyphenated suffix, it will be translated.
        # If there is no translation, the path segment is blank, begins with a
        # ":" (param key) or "*" (wildcard), the segment is returned untouched.
        def translate(segment, locale, scope)
          return segment if segment.empty?

          if segment.starts_with?(':'.freeze)
            named_param, hyphenized = segment.split('-'.freeze, 2)
            return "#{named_param}-#{translate(hyphenized, locale, scope)}" if hyphenized
          end

          return segment if segment.starts_with?('('.freeze) || segment.starts_with?('*'.freeze) || segment.include?(':'.freeze)

          appended_part = segment.slice!(/(\()$/)
          str = translatable_segment(segment)

          (translate_string(str, locale, scope) || segment) + appended_part.to_s
        end
      end
    end
  end
end
