module RouteTranslator
  module Translator
    module RouteHelpers
      class << self
        private

        def add_helpers_to_test_cases(helper_container)
          %w(ActionController ActionMailer ActionView).each do |klass_name|
            next unless Module.const_defined?(klass_name)
            klass_name.constantize::TestCase.__send__(:include, helper_container)
          end
        end
      end

      module_function

      # Add standard route helpers for default locale e.g.
      #   I18n.locale = :de
      #   people_path -> people_de_path
      #   I18n.locale = :fr
      #   people_path -> people_fr_path
      def add(old_name, named_route_collection)
        if named_route_collection.respond_to?(:url_helpers_module)
          url_helpers_module = named_route_collection.url_helpers_module
          path_helpers_module = named_route_collection.path_helpers_module
          url_helpers_list = named_route_collection.helper_names
          path_helpers_list = named_route_collection.helper_names
        else
          url_helpers_module = named_route_collection.module
          path_helpers_module = named_route_collection.module
          url_helpers_list = named_route_collection.helpers
          path_helpers_list = named_route_collection.helpers
        end

        [
          ['path', path_helpers_module, path_helpers_list],
          ['url', url_helpers_module, url_helpers_list]
        ].each do |suffix, helper_container, helper_list|
          new_helper_name = "#{old_name}_#{suffix}"

          helper_list.push(new_helper_name.to_sym) unless helper_list.include?(new_helper_name.to_sym)

          helper_container.__send__(:define_method, new_helper_name) do |*args|
            __send__(Translator.route_name_for(args, old_name, suffix, self), *args)
          end

          add_helpers_to_test_cases(helper_container)
        end
      end
    end
  end
end
