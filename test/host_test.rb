# frozen_string_literal: true

require 'test_helper'

class TestHostsFromLocale < Minitest::Test
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::I18nHelper
  include RouteTranslator::RoutesHelper

  def setup
    setup_config
    setup_i18n

    config host_locales: {
      '*.something.es'          => :es,
      '*.ru.subdomain.domain.*' => :ru,
      'russia.something.net'    => :ru,
      '*.com'                   => :en
    }
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
    config host_locales: { 'russia.*' => :ru, '*.com' => :en }

    assert_equal :ru, RouteTranslator::Host.locale_from_host('russia.com')

    config host_locales: { '*.com' => :en, 'russia.*' => :ru }

    assert_equal :en, RouteTranslator::Host.locale_from_host('russia.com')
  end

  def test_nil_if_no_matches
    assert_nil RouteTranslator::Host.locale_from_host('nomatches.co.uk')
  end

  def test_readme_examples_work
    config host_locales: {
      '*.es'                 => :es, # matches ['domain.es', 'subdomain.domain.es', 'www.long.string.of.subdomains.es'] etc.
      'ru.wikipedia.*'       => :ru, # matches ['ru.wikipedia.org', 'ru.wikipedia.net', 'ru.wikipedia.com'] etc.
      '*.subdomain.domain.*' => :ru, # matches ['subdomain.domain.org', 'www.subdomain.domain.net'] etc.
      'news.bbc.co.uk'       => :en # matches ['news.bbc.co.uk'] only
    }

    examples_es = ['domain.es', 'subdomain.domain.es', 'www.long.string.of.subdomains.es']
    examples_ru = ['ru.wikipedia.org', 'ru.wikipedia.net', 'ru.wikipedia.com']
    examples_ru_alt = ['subdomain.domain.org', 'www.subdomain.domain.net']
    examples_en = ['news.bbc.co.uk']

    examples_es.each do |domain|
      assert_equal :es, RouteTranslator::Host.locale_from_host(domain)
    end

    examples_ru.each do |domain|
      assert_equal :ru, RouteTranslator::Host.locale_from_host(domain)
    end

    examples_ru_alt.each do |domain|
      assert_equal :ru, RouteTranslator::Host.locale_from_host(domain)
    end

    examples_en.each do |domain|
      assert_equal :en, RouteTranslator::Host.locale_from_host(domain)
    end
  end
end
