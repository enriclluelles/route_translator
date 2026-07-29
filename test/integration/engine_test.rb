# frozen_string_literal: true

require 'test_helper'

class EngineTest < ActionDispatch::IntegrationTest
  def teardown
    Rails.application.reload_routes!
  end

  def test_with_engine_inside_localized_block
    Rails.application.routes.draw do
      localized do
        mount Blorgh::Engine, at: '/blorgh'
      end

      get 'engine_es', to: 'dummy#engine_es'
    end

    get '/engine_es'

    assert_response :success
    assert_equal '/es/blorgh/posts', response.body
  end

  def test_with_engine_outside_localized_block
    Rails.application.routes.draw do
      mount Blorgh::Engine, at: '/blorgh'

      get 'engine', to: 'dummy#engine'
    end

    get '/engine'

    assert_response :success
    assert_equal '/blorgh/posts', response.body
  end
end
