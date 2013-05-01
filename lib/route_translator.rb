require 'active_support'
require 'action_controller'
require 'action_mailer'
require 'action_dispatch'

require 'route_translator/extensions'
require 'route_translator/translator'

module RouteTranslator

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/.freeze

  Configuration = Struct.new(:force_locale, :generate_unlocalized_routes, :translation_file, :locale_param_key)

  def self.config(&block)
    @config ||= Configuration.new
    @config.force_locale ||= false
    @config.generate_unlocalized_routes ||= false
    @config.locale_param_key ||= :locale
    yield @config if block
    @config
  end

  def self.locale_param_key
    self.config.locale_param_key
  end

end
