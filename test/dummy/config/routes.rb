Dummy::Application.routes.draw do
  localized do
    get 'dummy', :to => 'dummy#dummy'
  end
  mount DummyMountedApp.new => '/dummy_mounted_app'
end
