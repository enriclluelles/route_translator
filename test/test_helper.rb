# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'simplecov'

SimpleCov.start 'rails' do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  # TODO: Remove this exclusion when dropping Ruby 3.1 support
  if RUBY_VERSION.start_with?('3.1')
    add_filter %w[lib/route_translator/extensions/mapper.rb lib/route_translator/extensions/route_set.rb]
  end

  add_filter %w[version.rb lib/generators/route_translator/templates]
end

require 'minitest/autorun'
require 'minitest/mock'

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
