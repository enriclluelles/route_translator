# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'simplecov'

SimpleCov.start do
  if ENV['CI']
    source_in_json false

    formatter SimpleCov::Formatter::JSONFormatter
  end

  skip %w[version.rb lib/generators/route_translator/templates]
end

require 'minitest/autorun'

require 'i18n'

require 'rails'
require 'action_controller/railtie'
require 'action_mailer/railtie'

require 'route_translator'

require 'byebug'

RouteTranslator.deprecator.silenced = true

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

Dir[File.expand_path('support/*.rb', __dir__)].each do |helper|
  require helper
end
