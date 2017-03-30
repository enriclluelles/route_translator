# frozen_string_literal: true

require 'active_support'

require File.expand_path('../route_translator/extensions', __FILE__)
require File.expand_path('../route_translator/translator', __FILE__)
require File.expand_path('../route_translator/host', __FILE__)

module RouteTranslator
  extend RouteTranslator::Host

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/

  Configuration = Struct.new(:available_locales, :disable_fallback, :force_locale,
                             :hide_locale, :host_locales, :generate_unlocalized_routes,
                             :generate_unnamed_unlocalized_routes, :locale_param_key,
                             :locale_segment_proc)

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
    @config.locale_segment_proc                 ||= nil

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
