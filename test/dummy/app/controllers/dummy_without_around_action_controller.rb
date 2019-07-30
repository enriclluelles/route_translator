# frozen_string_literal: true

class DummyWithoutAroundActionController < ActionController::Base
  def dummy
    render plain: I18n.locale
  end
end
