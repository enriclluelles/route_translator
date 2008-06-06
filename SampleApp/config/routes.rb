ActionController::Routing::Routes.draw do |map|

  map.resources :users

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'users', :action => 'index'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
ActionController::Routing::Translator.translate_from_files