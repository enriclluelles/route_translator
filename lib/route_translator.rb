# frozen_string_literal: true

require 'active_support'

require_relative 'route_translator/available_locales'
require_relative 'route_translator/extensions'
require_relative 'route_translator/translator'
require_relative 'route_translator/host'
require_relative 'route_translator/version'

module RouteTranslator
  extend RouteTranslator::Host

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/

  DEFAULT_CONFIGURATION = {
    available_locales:                   [],
    disable_fallback:                    false,
    force_locale:                        false,
    generate_unlocalized_routes:         false,
    generate_unnamed_unlocalized_routes: false,
    hide_locale:                         false,
    host_locales:                        {},
    locale_param_key:                    :locale,
    locale_segment_proc:                 false
  }.freeze

  Configuration = Struct.new(*DEFAULT_CONFIGURATION.keys) do
    def []=(*args)
      AvailableLocales.clear if args.first&.to_sym == :available_locales
      super
    end

    def available_locales=(value)
      self[:available_locales] = value
    end
  end

  class << self
    private

    def resolve_host_locale_config_conflicts
      @config.force_locale                        = false
      @config.generate_unlocalized_routes         = false
      @config.generate_unnamed_unlocalized_routes = false
      @config.hide_locale                         = true
    end

    def check_deprecations; end
  end

  module_function

  def config
    @config ||= Configuration.new

    DEFAULT_CONFIGURATION.each do |option, value|
      next unless @config[option].nil?

      @config[option] = value.duplicable? ? value.dup : value
    end

    if block_given?
      yield @config
      AvailableLocales.clear
    end

    resolve_host_locale_config_conflicts if @config.host_locales.present?
    check_deprecations

    @config
  end

  def reset_config
    @config = nil
    AvailableLocales.clear

    config
  end

  def available_locales
    AvailableLocales.locales
  end

  def available_locale?(locale)
    AvailableLocales.include?(locale)
  end

  def locale_param_key
    config.locale_param_key
  end

  def locale_from_params(params)
    locale = params[config.locale_param_key]&.to_sym
    locale if available_locale?(locale)
  end

  def locale_from_request(request)
    locale_from_params(request.params) || Host.locale_from_host(request.host)
  end

  def deprecator
    @deprecator ||= ActiveSupport::Deprecation.new(RouteTranslator::VERSION, 'RouteTranslator')
  end
end
