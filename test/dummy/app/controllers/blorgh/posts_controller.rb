# frozen_string_literal: true

module Blorgh
  class PostsController < ApplicationController
    around_action :set_locale_from_url

    def index
      render plain: I18n.locale
    end
  end
end
