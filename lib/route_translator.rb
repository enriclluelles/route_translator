require 'active_support'
require 'action_controller'
require 'action_mailer'
require 'action_dispatch'

require 'route_translator/route_set'
require 'route_translator/railtie' if defined?(Rails::Railtie)

module RouteTranslator

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/.freeze
  LOCALE_PARAM_KEY = :locale
  ROUTE_HELPER_CONTAINER = [
    ActionController::Base,
    ActionView::Base,
    ActionMailer::Base,
    ActionDispatch::Routing::UrlFor
  ].freeze

  Configuration = Struct.new(:force_locale, :generate_unlocalized_routes)

  def self.locale_suffix locale
    locale.to_s.underscore
  end

  def self.config
    @config ||= Configuration.new
  end

  # Attributes

  module Controller
    def set_locale_from_url
      I18n.locale = params[RouteTranslator::LOCALE_PARAM_KEY]
    end
  end

  module Mapper
    #yield the block and add all the routes created
    #in it to the localized_routes array
    def localized
      routes_before = @set.routes.map(&:to_s)
      yield
      routes_after = @set.routes.map(&:to_s)
      @set.localized_routes ||= []
      @set.localized_routes.concat(routes_after - routes_before)
      @set.localized_routes.uniq!
    end
  end

  ActiveSupport.run_load_hooks(:route_translator, self)
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

ActionController::Base.send(:include, RouteTranslator::Controller)
ActionDispatch::Routing::Mapper.send(:include, RouteTranslator::Mapper)
ActionDispatch::Routing::RouteSet.send(:include, RouteTranslator::RouteSet)
