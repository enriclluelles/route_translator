module Blorgh
  class PostsController < ActionController::Base
    def index; render text: I18n.locale end
  end
end