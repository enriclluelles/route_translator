#encoding: utf-8

require 'minitest/autorun'
require 'minitest/mock'

require 'i18n'
begin
  I18n.enforce_available_locales = true
rescue NoMethodError
end

require "rails"
require "action_controller/railtie"

require 'route_translator'

module ActionDispatch
  class TestRequest < Request
    def initialize(env = {})
      super(DEFAULT_ENV.merge(env))

      self.host        = 'test.host'
      self.remote_addr = '0.0.0.0'
      self.user_agent  = 'Rails Testing'
    end
  end
end

Dir[File.expand_path('../support/*.rb', __FILE__)].each do |helper|
  require helper
end
