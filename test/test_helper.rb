require 'test/unit'
require 'minitest/mock'
require 'minitest/unit'

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

module RouteTranslator
  module TestHelper
    def draw_routes(&block)
      @routes.draw(&block)
      if @routes.respond_to?(:install_helpers)
        @routes.install_helpers 
      else
        ActionView::Base.send(:include, @routes.url_helpers)
        ActionController::Base.send(:include, @routes.url_helpers)
      end
    end

    def config_default_locale_settings(locale)
      I18n.default_locale = locale
    end

    def config_force_locale(boolean)
      RouteTranslator.config.force_locale = boolean
    end

    def config_generate_unlocalized_routes(boolean)
      RouteTranslator.config.generate_unlocalized_routes = boolean
    end

    def config_translation_file (file)
      RouteTranslator.config.translation_file = file
    end

    def path_string(route)
      path = route.respond_to?(:path) ? route.path : route.to_s.split(' ')[1]
      path.respond_to?(:spec) ? path.spec.to_s : path.to_s
    end

    def named_route(name)
      @routes.routes.detect{ |r| r.name == name }
    end

    def formatted_root_route?
      b = ActionPack::VERSION::MAJOR == 3 && ActionPack::VERSION::MINOR > 0
      b ||= ActionPack::VERSION::MAJOR == 4
      !b
    end

    def print_routes(route_set)
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
      controller = ActionController::Base.new
      view = ActionView::Base.new
      helpers.each do |helper|
        ['url', 'path'].each do |suffix|
          [controller, view].each { |obj| assert_respond_to obj, "#{helper}_#{suffix}".to_sym }
        end
      end
    end

    # Hack for compatibility between Rails 4 and Rails 3
    def assert_unrecognized_route(route_path, options)
      assert_raise ActionController::RoutingError do
        begin
        assert_routing route_path, options
        rescue Minitest::Assertion => m
          raise ActionController::RoutingError.new("")
        end
      end
    end
  end
end
