# frozen_string_literal: true

require 'test_helper'

class ScopedRootController < ApplicationController
  def show
    head :ok
  end
end

class ScopedRootRoutingTest < ActiveSupport::TestCase
  include RouteTranslator::ConfigurationHelper
  include RouteTranslator::I18nHelper

  def setup
    setup_config
    setup_i18n
    @enforce_available_locales = I18n.enforce_available_locales
    I18n.available_locales = %i[fr en]
    I18n.default_locale = :fr
    I18n.enforce_available_locales = false
    I18n.load_path = []
    I18n.backend = I18n::Backend::Simple.new
    @routes = ActionDispatch::Routing::RouteSet.new
    draw_scoped_root
  end

  def teardown
    I18n.enforce_available_locales = @enforce_available_locales
    teardown_i18n
    teardown_config
  end

  def test_default_locale_recognition
    assert_root '/', locale: 'fr'
    assert_root '/2', locale: 'fr', scoped_partner_id: '2'
    assert_root '/2.json', locale: 'fr', scoped_partner_id: '2', format: 'json'
  end

  def test_prefixed_locale_recognition_without_partner
    assert_root '/en', locale: 'en'
    assert_root '/en.json', locale: 'en', format: 'json'
  end

  def test_prefixed_locale_recognition_with_partner
    assert_root '/en/2', locale: 'en', scoped_partner_id: '2'
    assert_root '/en/2.json', locale: 'en', scoped_partner_id: '2', format: 'json'
  end

  def test_partner_requires_a_separate_segment
    assert_not_found '/en2'
  end

  def test_numeric_and_subdomain_constraints
    %w[/abc /2abc /enabc /en/abc /en/2abc].each do |path|
      assert_not_found path
    end
    %w[/ /2 /en /en/2 /en2].each do |path|
      assert_not_found path, host: 'other.example.com'
    end
  end

  def test_default_locale_generation
    helpers = @routes.url_helpers

    assert_equal '/', helpers.root_fr_path
    assert_equal '/2', helpers.root_fr_path(scoped_partner_id: 2)
    assert_equal '/2.json', helpers.root_fr_path(scoped_partner_id: 2, format: 'json')
  end

  def test_prefixed_locale_generation
    helpers = @routes.url_helpers

    assert_equal '/en', helpers.root_en_path
    assert_equal '/en/2', helpers.root_en_path(scoped_partner_id: 2)
    assert_equal '/en/2.json', helpers.root_en_path(scoped_partner_id: 2, format: 'json')
    assert_equal 'http://workspace.example.com/en/2', helpers.root_en_url(host: 'workspace.example.com', scoped_partner_id: 2)
    I18n.with_locale(:en) do
      assert_equal '/en/2', helpers.root_path(scoped_partner_id: 2)
    end
  end

  def test_mixed_case_locale_recognition
    I18n.available_locales = %i[fr pt-BR]
    draw_scoped_root

    assert_root '/pt-br', locale: 'pt-BR'
    assert_root '/pt-br/2', locale: 'pt-BR', scoped_partner_id: '2'
    assert_not_found '/pt-br2'
  end

  def test_mixed_case_locale_generation
    I18n.available_locales = %i[fr pt-BR]
    draw_scoped_root

    assert_equal '/pt-br', @routes.url_helpers.root_pt_br_path
    assert_equal '/pt-br/2', @routes.url_helpers.root_pt_br_path(scoped_partner_id: 2)
  end

  def test_forced_default_locale
    config force_locale: true
    draw_scoped_root

    assert_root '/fr', locale: 'fr'
    assert_root '/fr/2', locale: 'fr', scoped_partner_id: '2'
    assert_equal '/fr/2', @routes.url_helpers.root_fr_path(scoped_partner_id: 2)
  end

  def test_hidden_locale_generation
    config hide_locale: true
    draw_scoped_root

    assert_equal '/', @routes.url_helpers.root_en_path
    assert_equal '/2', @routes.url_helpers.root_en_path(scoped_partner_id: 2)
  end

  def test_root_without_format
    draw_scoped_root(format: false)

    assert_root '/en', locale: 'en'
    assert_root '/en/2', locale: 'en', scoped_partner_id: '2'
    assert_not_found '/en/2.json'
    assert_equal '/en/2', @routes.url_helpers.root_en_path(scoped_partner_id: 2)
  end

  def test_unscoped_root_is_unchanged
    @routes.draw do
      localized do
        root to: 'scoped_root#show'
      end
    end

    assert_equal '/en', @routes.url_helpers.root_en_path
    assert_equal '/en?format=json', @routes.url_helpers.root_en_path(format: 'json')
    assert_equal '/?format=json', @routes.url_helpers.root_fr_path(format: 'json')
  end

  def test_explicit_locale_is_not_prefixed_again
    @routes.draw do
      localized do
        scope ':locale' do
          root to: 'scoped_root#show'
        end
      end
    end

    assert_equal '/en', @routes.url_helpers.root_en_path
    assert_equal '/en.json', @routes.url_helpers.root_en_path(format: 'json')
  end

  private

  def draw_scoped_root(**options)
    @routes.draw do
      localized do
        constraints subdomain: 'workspace' do
          scope '(:scoped_partner_id)', constraints: { scoped_partner_id: /\d+/ } do
            root to: 'scoped_root#show', **options
          end
        end
      end
    end
  end

  def assert_root(path, **parameters)
    expected = { subdomain: 'workspace', controller: 'scoped_root', action: 'show', **parameters }

    assert_equal expected, @routes.recognize_path("http://workspace.example.com#{path}", method: :get)
  end

  def assert_not_found(path, host: 'workspace.example.com')
    response = Rack::MockRequest.new(@routes).get("http://#{host}#{path}")

    assert_equal 404, response.status, "Expected #{host}#{path} not to match"
  end
end
