# frozen_string_literal: true

require 'i18n'

require 'route_translator'

module Dummy
  class Application < Rails::Application
    config.active_support.deprecation = :log
    config.eager_load = false
    config.active_support.cache_format_version = 7.0 if Rails.version >= '7.0'
  end
end
