#encoding: utf-8
require File.expand_path('../test_helper', __FILE__)

class TestHostsFromLocale < MiniTest::Unit::TestCase

  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::I18nHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config
    setup_i18n

    config = host_locales_config_hash
    config['*.something.es']          = :es
    config['*.ru.subdomain.domain.*'] = :ru
    config['russia.something.net']    = :ru
    config['*.com']                   = :en

    config_host_locales(config)
  end

  def teardown
    teardown_i18n
    teardown_config
  end

  def test_wildcard_at_beginning_matches
    assert_equal :en, RouteTranslator::Host.locale_from_host('something.com')
  end

  def test_wildcard_at_beginning_with_subdomain_matches
    assert_equal :en, RouteTranslator::Host.locale_from_host('www.domain.com')
  end

  def test_wildcard_at_beginning_without_subdomain_matches
    assert_equal :en, RouteTranslator::Host.locale_from_host('domain.com')
  end

  def test_wildcard_at_end_with_subdomain_matches
    assert_equal :es, RouteTranslator::Host.locale_from_host('www.something.es')
  end

  def test_wildcard_at_end_without_subdomain_matches
    assert_equal :es, RouteTranslator::Host.locale_from_host('something.es')
  end

  def test_no_wildcard_matches
    assert_equal :ru, RouteTranslator::Host.locale_from_host('russia.something.net')
  end

  def test_multiple_wildcard_matches
    assert_equal :ru, RouteTranslator::Host.locale_from_host('www.ru.subdomain.domain.biz')
  end

  def test_case_is_ignored
    assert_equal :es, RouteTranslator::Host.locale_from_host('www.SoMeThInG.ES')
  end

  def test_precedence_if_more_than_one_match
    config = host_locales_config_hash
    config['russia.*'] = :ru
    config['*.com'] = :en
    config_host_locales(config)
    assert_equal :ru, RouteTranslator::Host.locale_from_host('russia.com')

    config = host_locales_config_hash
    config['*.com'] = :en
    config['russia.*'] = :ru
    config_host_locales(config)
    assert_equal :en, RouteTranslator::Host.locale_from_host('russia.com')
  end

  def test_default_locale_if_no_matches
    assert_equal I18n.default_locale, RouteTranslator::Host.locale_from_host('nomatches.co.uk')
  end

  def test_readme_examples_work
    config = host_locales_config_hash
    config['*.es']                  = :es # matches ['domain.es', 'subdomain.domain.es', 'www.long.string.of.subdomains.es'] etc.
    config['ru.wikipedia.*']        = :ru # matches ['ru.wikipedia.org', 'ru.wikipedia.net', 'ru.wikipedia.com'] etc.
    config['*.subdomain.domain.*']  = :ru # matches ['subdomain.domain.org', 'www.subdomain.domain.net'] etc.
    config['news.bbc.co.uk']        = :en # matches ['news.bbc.co.uk'] only

    config_host_locales(config)

    examples_1 = ['domain.es', 'subdomain.domain.es', 'www.long.string.of.subdomains.es']
    examples_2 = ['ru.wikipedia.org', 'ru.wikipedia.net', 'ru.wikipedia.com']
    examples_3 = ['subdomain.domain.org', 'www.subdomain.domain.net']
    examples_4 = ['news.bbc.co.uk']

    examples_1.each do |domain|
      assert_equal :es, RouteTranslator::Host.locale_from_host(domain)
    end

    examples_2.each do |domain|
      assert_equal :ru, RouteTranslator::Host.locale_from_host(domain)
    end

    examples_3.each do |domain|
      assert_equal :ru, RouteTranslator::Host.locale_from_host(domain)
    end

    examples_4.each do |domain|
      assert_equal :en, RouteTranslator::Host.locale_from_host(domain)
    end
  end
end
