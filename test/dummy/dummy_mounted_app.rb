class DummyMountedApp
  def call(_)
    [200, { 'Content-Type' => 'text/plain' }, ['Good']]
  end
end
