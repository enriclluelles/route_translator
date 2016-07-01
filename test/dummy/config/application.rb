require 'i18n'
require 'action_controller/railtie'

begin
  require 'active_resource/railtie'
rescue LoadError
  ''
end

require 'route_translator'

module Dummy
  class Application < Rails::Application
    # config.logger = Logger.new(File.new("/dev/null", 'w'))
    config.active_support.deprecation = :log
    config.i18n.enforce_available_locales = false
    config.eager_load = false
  end
end
