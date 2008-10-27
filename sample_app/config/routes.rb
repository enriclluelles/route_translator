ActionController::Routing::Routes.draw do |map|
  map.resources :users
#  map.root :controller => 'users'
end

ActionController::Routing::Translator.i18n
#ActionController::Routing::Translator.translate_from_file 'locales', 'i18n-routes.yml'
