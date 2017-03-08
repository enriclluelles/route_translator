Rails.application.routes.draw do
  localized do
    get 'dummy',  to: 'dummy#dummy'
    get 'show',   to: 'dummy#show'

    get 'optional(/:page)', to: 'dummy#optional', as: :optional
    get 'prefixed_optional(/p-:page)', to: 'dummy#prefixed_optional', as: :prefixed_optional

    get ':id-suffix', to: 'dummy#suffix'
  end

  get 'partial_caching', to: 'dummy#partial_caching'
  get 'native', to: 'dummy#native'
  get 'engine_es', to: 'dummy#engine_es'
  get 'engine', to: 'dummy#engine'
  root to: 'dummy#dummy'

  mount DummyMountedApp.new => '/dummy_mounted_app'

  localized do
    mount Blorgh::Engine, at: '/blorgh'
  end
  mount Blorgh::Engine, at: '/blorgh'
end

Blorgh::Engine.routes.draw do
  resources :posts, only: :index
end
