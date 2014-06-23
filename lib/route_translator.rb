require 'active_support'
require 'action_controller'
require 'action_mailer'
require 'action_dispatch'

require File.expand_path('../route_translator/extensions', __FILE__)
require File.expand_path('../route_translator/translator', __FILE__)

module RouteTranslator

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/.freeze

  Configuration = Struct.new(:force_locale, :hide_locale,
                             :generate_unlocalized_routes, :locale_param_key,
                             :generate_unnamed_unlocalized_routes,
                             :tld_locales)

  def self.config(&block)
    @config                                     ||= Configuration.new
    @config.force_locale                        ||= false
    @config.hide_locale                         ||= false
    @config.generate_unlocalized_routes         ||= false
    @config.locale_param_key                    ||= :locale
    @config.generate_unnamed_unlocalized_routes ||= false
    @config.tld_locales                         ||= {}.with_indifferent_access
    yield @config if block
    resolve_config_conflicts
    @config
  end

  def self.resolve_config_conflicts
    if @config.tld_locales.present?
      @config.generate_unlocalized_routes, @config.generate_unnamed_unlocalized_routes = false, false
    end
  end

  def self.native_locale?(locale)
    !!locale.match(/native_/)
  end

  def self.native_locales
    config.tld_locales.values.map{|locale| :"native_#{locale}" }
  end

  def self.locale_param_key
    self.config.locale_param_key
  end
end
