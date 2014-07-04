#encoding: utf-8
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class TestHostsFromLocale < MiniTest::Unit::TestCase
  include RouteTranslator::TestHelper
  def setup
    I18n.backend        = I18n::Backend::Simple.new
    I18n.load_path      = [ File.expand_path('../locales/routes.yml', __FILE__) ]
    I18n.reload!

    config_host_locales({
      '*.something.es'           => :es,
      '*.ru.subdomain.domain.*'  => :ru,
      'russia.something.net'     => :ru,
      '*.com'                    => :en
    })
  end

  def teardown
    config_host_locales({})
    I18n.default_locale = :en
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
    config_host_locales({ 'russia.*'  => :ru, '*.com' => :en })
    assert_equal :ru, RouteTranslator::Host.locale_from_host('russia.com')

    config_host_locales({ '*.com' => :en, 'russia.*'  => :ru })
    assert_equal :en, RouteTranslator::Host.locale_from_host('russia.com')
  end

  def test_default_locale_if_no_matches
    assert_equal I18n.default_locale, RouteTranslator::Host.locale_from_host('nomatches.co.uk')
  end

  def test_readme_examples_work
    config_host_locales(
      {
        '*.es'                  => :es, # matches ['domain.es', 'subdomain.domain.es', 'www.long.string.of.subdomains.es'] etc.
        'ru.wikipedia.*'        => :ru, # matches ['ru.wikipedia.org', 'ru.wikipedia.net', 'ru.wikipedia.com'] etc.
        '*.subdomain.domain.*'  => :ru, # matches ['subdomain.domain.org', 'www.subdomain.domain.net'] etc.
        'news.bbc.co.uk'        => :en, # matches ['news.bbc.co.uk'] only
      }
    )

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
