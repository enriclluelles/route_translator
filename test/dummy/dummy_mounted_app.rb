require 'sinatra'
class DummyMountedApp < Sinatra::Base
  get "/" do
    "Good"
  end
end
