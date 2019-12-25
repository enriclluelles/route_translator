# frozen_string_literal: true

class DummyWithoutAroundActionController < ApplicationController
  def dummy
    render plain: I18n.locale
  end
end
