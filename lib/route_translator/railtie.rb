module RouteTranslator
  class Railtie < ::Rails::Railtie
    config.route_translator = ActiveSupport::OrderedOptions.new

    initializer "route_translator.set_configs" do |app|
      options = app.config.route_translator
      options.force_locale ||= false
      options.generate_unlocalized_routes ||= false
      options.translation_file ||= File.join(%w[config i18n-routes.yml])

      ActiveSupport.on_load :route_translator do
        options.each do |k, v|
          k = "#{k}="
          if config.respond_to?(k)
            config.send k, v
          else
            raise "Invalid option key: #{k}"
          end
        end
      end
    end
  end
end
