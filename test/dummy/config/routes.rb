require File.join(Dummy::Application.root, 'dummy_mounted_app.rb')

Dummy::Application.routes.draw do
  localized do
    get 'dummy',  :to => 'dummy#dummy'
    get 'show',   :to => 'dummy#show'

    get 'optional(/:page)', :to => 'dummy#optional', :as => :optional
    get 'prefixed_optional(/p-:page)', :to => 'dummy#prefixed_optional', :as => :prefixed_optional
  end

  root :to => 'dummy#dummy'

  mount DummyMountedApp.new => '/dummy_mounted_app'
end
