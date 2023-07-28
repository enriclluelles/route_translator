# frozen_string_literal: true

require 'test_helper'

class I18nSlashSeparatorTest < ActionDispatch::IntegrationTest
  include RouteTranslator::ConfigurationHelper

  def teardown
    teardown_config
  end

  def test_deprecation_when_default
    assert_deprecated('i18n_use_slash_separator', RouteTranslator.deprecator) do
      RouteTranslator.config
    end
  end

  def test_deprecation_when_false
    config_i18n_use_slash_separator false

    assert_deprecated('i18n_use_slash_separator', RouteTranslator.deprecator) do
      RouteTranslator.config
    end
  end

  def test_no_deprecation_when_true
    config_i18n_use_slash_separator true

    assert_not_deprecated(RouteTranslator.deprecator) do
      RouteTranslator.config
    end
  end
end
