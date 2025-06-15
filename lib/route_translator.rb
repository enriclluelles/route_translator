# frozen_string_literal: true

require 'active_support'

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

  Configuration = Struct.new(*DEFAULT_CONFIGURATION.keys)

  class << self
    private

    def resolve_host_locale_config_conflicts
      @config.force_locale                        = false
      @config.generate_unlocalized_routes         = false
      @config.generate_unnamed_unlocalized_routes = false
      @config.hide_locale                         = true

      @config.host_locales.delete_if { |_, locale| @config.available_locales.exclude?(locale.to_sym) }
    end

    def check_deprecations; end

    def set_available_locales
      locales = I18n.available_locales.dup

      if @config.available_locales.present?
        locales &= @config.available_locales.map(&:to_sym)
      end

      # Make sure the default locale is translated in last place to avoid
      # problems with wildcards when default locale is omitted in paths. The
      # default routes will catch all paths like wildcard if it is translated first.
      locales.delete I18n.default_locale
      locales.push I18n.default_locale

      @config.available_locales = locales
    end
  end

  module_function

  def config
    @config ||= Configuration.new

    DEFAULT_CONFIGURATION.each do |option, value|
      @config[option] ||= value
    end

    yield @config if block_given?

    set_available_locales
    resolve_host_locale_config_conflicts if @config.host_locales.present?
    check_deprecations

    @config
  end

  def reset_config
    @config = nil

    config
  end

  def available_locales
    config.available_locales
  end

  def locale_param_key
    config.locale_param_key
  end

  def locale_from_params(params)
    locale = params[config.locale_param_key]&.to_sym
    locale if available_locales.include?(locale)
  end

  def deprecator
    @deprecator ||= ActiveSupport::Deprecation.new(RouteTranslator::VERSION, 'RouteTranslator')
  end
end
