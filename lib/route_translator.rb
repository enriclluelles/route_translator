require 'active_support'

require File.expand_path('../route_translator/extensions', __FILE__)
require File.expand_path('../route_translator/translator', __FILE__)
require File.expand_path('../route_translator/host', __FILE__)

module RouteTranslator
  extend RouteTranslator::Host

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/.freeze

  Configuration = Struct.new(:force_locale, :hide_locale,
                             :generate_unlocalized_routes, :locale_param_key,
                             :generate_unnamed_unlocalized_routes, :available_locales,
                             :host_locales)

  def self.config(&block)
    @config                                     ||= Configuration.new
    @config.force_locale                        ||= false
    @config.hide_locale                         ||= false
    @config.generate_unlocalized_routes         ||= false
    @config.locale_param_key                    ||= :locale
    @config.generate_unnamed_unlocalized_routes ||= false
    @config.host_locales                        ||= ActiveSupport::OrderedHash.new
    @config.available_locales                   ||= nil
    yield @config if block
    resolve_config_conflicts
    @config
  end

  def self.resolve_config_conflicts
    if @config.host_locales.present?
      @config.generate_unlocalized_routes         = false
      @config.generate_unnamed_unlocalized_routes = false
      @config.force_locale                        = false
      @config.hide_locale                         = false
    end
  end

  def self.locale_param_key
    self.config.locale_param_key
  end
end
