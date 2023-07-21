# frozen_string_literal: true

require 'active_support'

require 'route_translator/extensions'
require 'route_translator/translator'
require 'route_translator/host'

module RouteTranslator
  extend RouteTranslator::Host

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/.freeze

  DEFAULT_CONFIGURATION = {
    available_locales:                   [],
    disable_fallback:                    false,
    force_locale:                        false,
    generate_unlocalized_routes:         false,
    generate_unnamed_unlocalized_routes: false,
    hide_locale:                         false,
    host_locales:                        {},
    locale_param_key:                    :locale,
    locale_segment_proc:                 false,
    generate_raw_named_localized_route:  false
  }.freeze

  Configuration = Struct.new(*DEFAULT_CONFIGURATION.keys)

  class << self
    private

    def resolve_host_locale_config_conflicts
      @config.force_locale                        = false
      @config.generate_unlocalized_routes         = false
      @config.generate_unnamed_unlocalized_routes = false
      @config.hide_locale                         = true
      @config.generate_raw_named_localized_route  = false
    end
  end

  module_function

  def config
    @config ||= Configuration.new

    DEFAULT_CONFIGURATION.each do |option, value|
      @config[option] ||= value
    end

    yield @config if block_given?

    resolve_host_locale_config_conflicts if @config.host_locales.present?

    @config
  end

  def reset_config
    @config = nil

    config
  end

  def available_locales
    locales = config.available_locales

    if locales.empty?
      I18n.available_locales.dup
    else
      locales.map(&:to_sym)
    end
  end

  def locale_param_key
    config.locale_param_key
  end

  def locale_from_params(params)
    locale = params[config.locale_param_key]&.to_sym
    locale if I18n.available_locales.include?(locale)
  end

  def generate_raw_named_localized_route
    return if config.available_locales.many?

    config.generate_raw_named_localized_route
  end
end
