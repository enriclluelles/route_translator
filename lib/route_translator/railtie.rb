# frozen_string_literal: true

require 'rails/railtie'

module RouteTranslator
  class Railtie < Rails::Railtie
    config.eager_load_namespaces << RouteTranslator
  end
end
