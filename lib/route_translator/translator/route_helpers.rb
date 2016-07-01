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
        helper_list = named_route_collection.helper_names

        %w(path url).each do |suffix|
          helper_container = named_route_collection.send(:"#{suffix}_helpers_module")
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
