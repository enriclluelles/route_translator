# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter %w(version.rb initializer.rb)
  end
end

require 'minitest/autorun'
require 'minitest/mock'

require 'i18n'

require 'rails'
require 'action_controller/railtie'
require 'action_mailer/railtie'

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

Minitest::Test = Minitest::Unit::TestCase unless defined?(Minitest::Test)
