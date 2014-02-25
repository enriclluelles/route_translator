class DummyMountedApp
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["Good"]]
  end
end
