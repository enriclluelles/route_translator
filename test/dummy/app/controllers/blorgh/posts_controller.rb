module Blorgh
  class PostsController < ActionController::Base
    def index
      render plain: I18n.locale
    end
  end
end
