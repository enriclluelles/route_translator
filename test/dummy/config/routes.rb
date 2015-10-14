require File.join(Dummy::Application.root, 'dummy_mounted_app.rb')

Dummy::Application.routes.draw do
  localized do
    get 'dummy',  :to => 'dummy#dummy'
    get 'show',   :to => 'dummy#show'
  end

  get 'native', :to => 'dummy#native'
  root :to => 'dummy#dummy'

  mount DummyMountedApp.new => '/dummy_mounted_app'
end
