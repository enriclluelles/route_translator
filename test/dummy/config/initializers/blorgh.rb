# frozen_string_literal: true

module Blorgh
  class Engine < Rails::Engine
    isolate_namespace Blorgh
  end
end

Blorgh::Engine.routes.draw do
  resources :posts, only: :index
end
