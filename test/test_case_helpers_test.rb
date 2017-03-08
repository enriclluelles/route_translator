require File.expand_path('../test_helper', __FILE__)

class TestCaseHelpersTest < MiniTest::Test
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config

    @routes = ActionDispatch::Routing::RouteSet.new

    config_default_locale_settings 'en'

    draw_routes do
      localized do
        resources :people
      end
    end
  end

  def teardown
    teardown_config
  end

  def test_action_controller_test_case_reads_default_urls
    test_case_reads_default_urls(ActionController::TestCase)
  end

  def test_action_view_test_case_reads_default_urls
    test_case_reads_default_urls(ActionView::TestCase)
  end

  def test_action_mailer_test_case_reads_default_urls
    test_case_reads_default_urls(ActionMailer::TestCase)
  end

  private

  def test_case_reads_default_urls(klass)
    test_case = klass.new(nil)

    # Not localized
    assert test_case.respond_to?(:people_path)
    assert test_case.respond_to?(:new_person_path)

    # Localized
    assert test_case.respond_to?(:people_en_path)
    assert test_case.respond_to?(:new_person_en_path)
  end
end

class TestController < ActionController::Base
  def test
    render plain: nil
  end
end

class TestControllerTest < ActionController::TestCase
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config

    @routes = ActionDispatch::Routing::RouteSet.new

    config_default_locale_settings 'en'

    draw_routes do
      get :test, to: 'test#test'
    end
  end

  def teardown
    teardown_config
  end

  def test_responds_to__routes
    assert _routes
  end

  def test_application_controller_test_case
    get :test

    assert_response :success
  end
end
