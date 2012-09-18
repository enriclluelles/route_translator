require "rails"

module Rails
  class Application
    class RoutesReloader
      alias :__reload__! :reload!

      def reload!
        result = __reload__!

        route_sets.each do |routes|
          routes.default_locale = I18n.default_locale
          routes.translate_from_file
        end

        result
      end
    end
  end
end