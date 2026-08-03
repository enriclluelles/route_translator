# frozen_string_literal: true

require 'action_dispatch'

# Rails 8.1 changed `Mapper#add_route`'s arity. Load the matching extension
# pair because both override that private Rails method.
# TODO: Remove `else` branch when dropping Rails < 8.1 support
if ActionDispatch::Routing::Mapper.instance_method(:add_route).arity == 12
  require_relative 'extensions/mapper'
  require_relative 'extensions/route_set'
else
  require_relative 'extensions/legacy/mapper'
  require_relative 'extensions/legacy/route_set'
end

require_relative 'extensions/action_controller'
