Dummy::Application.routes.draw do
  localized do
    get 'dummy', :to => 'dummy#dummy'
  end
  mount DummyMountedApp => '/dummy_mounted_app'
end
