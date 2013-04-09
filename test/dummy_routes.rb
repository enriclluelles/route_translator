Rails.application.routes.draw do
  localized do
    root :to => 'people#index'
  end
end
