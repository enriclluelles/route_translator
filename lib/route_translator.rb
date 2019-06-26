# frozen_string_literal: true

require 'active_support'

require 'route_translator/extensions'
require 'route_translator/translator'
require 'route_translator/host'
require 'route_translator/host_path_consistency_lambdas'
require 'route_translator/locale_sanitizer'

module RouteTranslator
  extend RouteTranslator::Host

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/.freeze

  Configuration = Struct.new(:available_locales, :disable_fallback, :force_locale,
                             :hide_locale, :host_locales, :generate_unlocalized_routes,
                             :generate_unnamed_unlocalized_routes, :locale_param_key,
                             :locale_segment_proc, :verify_host_path_consistency)

  class << self
    private

    def resolve_host_locale_config_conflicts
      @config.force_locale                        = false
      @config.hide_locale                         = false
      @config.generate_unlocalized_routes         = false
      @config.generate_unnamed_unlocalized_routes = false
    end
  end

  module_function

  def config(&block)
    @config                                     ||= Configuration.new
    @config.available_locales                   ||= []
    @config.disable_fallback                    ||= false
    @config.force_locale                        ||= false
    @config.hide_locale                         ||= false
    @config.host_locales                        ||= ActiveSupport::OrderedHash.new
    @config.generate_unlocalized_routes         ||= false
    @config.generate_unnamed_unlocalized_routes ||= false
    @config.locale_param_key                    ||= :locale
    @config.locale_segment_proc                 ||= false
    @config.verify_host_path_consistency        ||= false

    yield @config if block

    resolve_host_locale_config_conflicts unless @config.host_locales.empty?

    @config
  end

  def available_locales
    locales = config.available_locales

    if locales.any?
      locales.map(&:to_sym)
    else
      I18n.available_locales.dup
    end
  end

  def locale_param_key
    config.locale_param_key
  end
end
