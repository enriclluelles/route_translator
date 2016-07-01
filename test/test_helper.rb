# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter %w(version.rb)
end

require 'minitest/autorun'
require 'minitest/mock'

require 'i18n'

require 'rails'
require 'action_controller/railtie'
require 'action_mailer/railtie'

require 'route_translator'

require 'byebug'

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
