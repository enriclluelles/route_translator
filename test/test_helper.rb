require 'test/unit'
require 'mocha'

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


class StubbedI18nBackend
  @@translations = {
    'es' => { 'people' => 'gente'},
    'fr' => {} # empty on purpose to test behaviour on incompleteness scenarios
  }

  def self.translate(locale, key, options)
    @@translations[locale.to_s][key] || options[:default]
  rescue
    options[:default]
  end

  def self.available_locales
    @@translations.keys
  end
end

module RouteTranslator
  module TestHelper
    def path_string(route)
      path = route.respond_to?(:path) ? route.path : route.to_s.split(' ')[1]
      path.respond_to?(:spec) ? path.spec.to_s : path.to_s
    end

    def named_route(name)
      @routes.routes.detect{ |r| r.name == name }
    end

    def formatted_root_route?
      !(defined?(ActionPack) && ActionPack::VERSION::MAJOR == 3 && ActionPack::VERSION::MINOR > 0)
    end

    def setup_application
      return if defined?(@@app)

      app = @@app = Class.new(Rails::Application)
      app.config.active_support.deprecation = :stderr
      app.paths["log"] = "#{tmp_path}/log/test.log"
      app.paths["config/routes"] = File.join(app_path, routes_config)
      app.initialize!
      Rails.application = app
    end

    def app
      @@app
    end

    def tmp_path(*args)
      @tmp_path ||= File.join(File.dirname(__FILE__), "tmp")
      File.join(@tmp_path, *args)
    end

    def app_path(*args)
      tmp_path(*%w[app] + args)
    end

    def load_routes_file(path)
      app.routes_reloader.paths.clear
      app.routes_reloader.paths.unshift(path)
      app.reload_routes!
    end

    def routes_config
      @@routes_config ||= File.join("config", "routes.rb")
    end

    def print_routes (route_set)
      require 'rails/application/route_inspector'
      inspector = Rails::Application::RouteInspector.new
      puts inspector.format(route_set.routes, ENV['CONTROLLER']).join "\n"
    rescue LoadError
    end

    def assert_helpers_include(*helpers)
      helpers.each do |helper|
        ['url', 'path'].each do |suffix|
          [@controller, @view].each { |obj| assert_respond_to obj, "#{helper}_#{suffix}".to_sym }
        end
      end
    end

    def assert_unrecognized_route(route_path, options)
      assert_raise ActionController::RoutingError do
        assert_routing route_path, options
      end
    end
  end
end
