# frozen_string_literal: true

module RouteTranslator
  class Route
    attr_reader :route_set, :path, :name, :options_constraints, :options, :mapping

    def initialize(route_set, path, name, options_constraints, options, mapping)
      @route_set           = route_set
      @path                = path
      @name                = name
      @options_constraints = options_constraints
      @options             = options
      @mapping             = mapping
    end

    def scope
      @scope ||=
        if mapping.defaults[:controller]
          if RouteTranslator.config.i18n_use_controller_path
            %i[routes controllers].push mapping.defaults[:controller]
          else
            %i[routes controllers].concat mapping.defaults[:controller].split('/').map(&:to_sym)
          end
        else
          %i[routes controllers]
        end
    end
  end
end
