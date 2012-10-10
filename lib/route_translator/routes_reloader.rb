require "rails"

module Rails
  class Application
      alias :reload_routes_without_translator! :reload_routes!
      def reload_routes!
        result = reload_routes_without_translator!

        self.routes.default_locale = I18n.default_locale
        self.routes.translate_from_file

        result
      end
  end
end
