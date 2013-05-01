require 'test/unit'
require 'minitest/mock'

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
  DEFAULT_TRANSLATIONS = {
    'es' => {
      'people' => 'gente',
      'products' => 'productos'
    },
    'fr' => {} # empty on purpose to test behaviour on incompleteness scenarios
  }

  def initialize(translations = nil)
    @translations = translations || DEFAULT_TRANSLATIONS
  end

  def translate(locale, key, options)
    @translations[locale.to_s][key] || options[:default]
  rescue
    options[:default]
  end

  def available_locales
    @translations.keys
  end

  def self.available_locales
    new.available_locales
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

    def setup_application(routes_file = "")
      if defined?(Rails)
        Rails.application = nil
        app = @@app = Class.new(Rails::Application)
        app.config.active_support.deprecation = :stderr
        app.paths.config.routes << routes_file rescue NoMethodError
        app.paths['config/routes'] << routes_file
        app.initialize!
        Rails.application = app
      end
    end

    def app
      @@app
    end

    def print_routes (route_set)
      all_routes = route_set.routes

      routes = all_routes.collect do |route|

        reqs = route.requirements.dup
        reqs[:to] = route.app unless route.app.class.name.to_s =~ /^ActionDispatch::Routing/
        reqs = reqs.empty? ? "" : reqs.inspect

        {:name => route.name.to_s, :verb => route.verb.to_s, :path => route.path.try(:spec).to_s, :reqs => reqs}
      end

      name_width = routes.map{ |r| r[:name].length }.max
      verb_width = routes.map{ |r| r[:verb].length }.max
      path_width = routes.map{ |r| r[:path].to_s.length }.max

      routes.each do |r|
        puts "#{r[:name].rjust(name_width)} #{r[:verb].ljust(verb_width)} #{r[:path].to_s.ljust(path_width)} #{r[:reqs]}"
      end
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
