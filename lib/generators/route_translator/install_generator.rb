# frozen_string_literal: true

module RouteTranslator
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Copy RouteTranslator default files'
      source_root File.expand_path('templates', __dir__)

      def copy_config
        template 'config/initializers/route_translator.rb'
      end
    end
  end
end
