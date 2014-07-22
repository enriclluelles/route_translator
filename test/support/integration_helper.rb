require File.expand_path('../../dummy/dummy_mounted_app', __FILE__)
require File.expand_path('../../dummy/config/environment', __FILE__)

def integration_test_suite_parent_class
  defined?(ActionDispatch::IntegrationTest) ? ActionDispatch::IntegrationTest : ActionController::IntegrationTest
end
