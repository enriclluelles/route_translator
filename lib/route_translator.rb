require 'active_support'

require File.expand_path('../route_translator/extensions', __FILE__)
require File.expand_path('../route_translator/translator', __FILE__)
require File.expand_path('../route_translator/host', __FILE__)

module RouteTranslator
  extend RouteTranslator::Host

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/

  Configuration = Struct.new(:force_locale, :hide_locale,
                             :generate_unlocalized_routes, :locale_param_key,
                             :generate_unnamed_unlocalized_routes, :available_locales,
                             :host_locales, :disable_fallback)

  class << self
    private

    def resolve_host_locale_config_conflicts
      @config.generate_unlocalized_routes         = false
      @config.generate_unnamed_unlocalized_routes = false
      @config.force_locale                        = false
      @config.hide_locale                         = false
    end
  end

  module_function

  def config(&block)
    @config                                     ||= Configuration.new
    @config.force_locale                        ||= false
    @config.hide_locale                         ||= false
    @config.generate_unlocalized_routes         ||= false
    @config.locale_param_key                    ||= :locale
    @config.generate_unnamed_unlocalized_routes ||= false
    @config.host_locales                        ||= ActiveSupport::OrderedHash.new
    @config.available_locales                   ||= []
    @config.disable_fallback                    ||= false
    yield @config if block
    resolve_host_locale_config_conflicts unless @config.host_locales.empty?
    @config
  end

  def locale_param_key
    config.locale_param_key
  end
end
