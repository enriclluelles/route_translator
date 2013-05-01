require "action_controller/railtie"
require "active_resource/railtie"
require "route_translator"

module Dummy
  class Application < Rails::Application
    # config.logger = Logger.new(File.new("/dev/null", 'w'))
    config.active_support.deprecation = :log
  end
end
