module RouteTranslator
  module RoutesHelper
    def draw_routes(&block)
      @routes.draw(&block)
      if @routes.respond_to?(:install_helpers)
        @routes.install_helpers
      else
        %w(ActionController ActionMailer ActionView).each do |klass_name|
          next unless Module.const_defined?(klass_name)
          klass_name.constantize::Base.__send__(:include, @routes.url_helpers)
        end
      end
    end

    def path_string(route)
      path = route.respond_to?(:path) ? route.path : route.to_s.split(' ')[1]
      path.respond_to?(:spec) ? path.spec.to_s : path.to_s
    end

    def named_route(name)
      @routes.routes.detect { |r| r.name == name }
    end

    def print_routes(route_set)
      all_routes = route_set.routes

      routes = all_routes.collect do |route|
        reqs = route.requirements.dup
        reqs[:to] = route.app unless route.app.class.name.to_s =~ /^ActionDispatch::Routing/
        reqs = reqs.empty? ? '' : reqs.inspect

        path = route.path
        path = path.spec if path.respond_to?(:spec)
        path = path.to_s

        { name: route.name.to_s, verb: route.verb.to_s, path: path, reqs: reqs }
      end

      name_width = routes.map { |r| r[:name].length }.max
      verb_width = routes.map { |r| r[:verb].length }.max
      path_width = routes.map { |r| r[:path].to_s.length }.max

      puts
      routes.each do |r|
        puts "#{r[:name].rjust(name_width)} #{r[:verb].ljust(verb_width)} #{r[:path].to_s.ljust(path_width)} #{r[:reqs]}"
      end
      puts
    end
  end
end
