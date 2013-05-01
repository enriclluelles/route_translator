require 'active_support'
require 'action_controller'
require 'action_mailer'
require 'action_dispatch'

require 'route_translator/extensions'
require 'route_translator/translator'

module RouteTranslator

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/.freeze
  ROUTE_HELPER_CONTAINER = [
    ActionController::Base,
    ActionView::Base,
    ActionMailer::Base,
    ActionDispatch::Routing::UrlFor
  ].freeze

  Configuration = Struct.new(:force_locale, :generate_unlocalized_routes, :translation_file, :locale_param_key)

  def self.locale_suffix locale
    locale.to_s.underscore
  end

  def self.config(&block)
    @config ||= Configuration.new
    @config.force_locale ||= false
    @config.generate_unlocalized_routes ||= false
    @config.translation_file ||= File.join(%w[config i18n-routes.yml])
    @config.locale_param_key ||= :locale
    yield @config if block
    @config
  end

  def self.locale_param_key
    self.config.locale_param_key
  end

end

# Add locale_suffix to controllers, views and mailers
RouteTranslator::ROUTE_HELPER_CONTAINER.each do |klass|
  klass.class_eval do
    private
    def locale_suffix locale
      RouteTranslator.locale_suffix locale
    end
  end
end
