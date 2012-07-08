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
