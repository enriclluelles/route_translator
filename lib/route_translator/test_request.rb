module ActionDispatch
  class TestRequest < Request
    def initialize(env = {})
      env = Rails.application.env_config.merge(env) if defined?(Rails.application) && Rails.application
      super(DEFAULT_ENV.merge(env))

      self.host        = 'test.host'
      self.remote_addr = '0.0.0.0'
      self.user_agent  = 'Rails Testing'
    end
  end
end