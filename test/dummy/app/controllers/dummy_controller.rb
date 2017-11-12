# frozen_string_literal: true

class DummyController < ApplicationController
  around_action :set_locale_from_url

  def dummy
    render plain: I18n.locale
  end

  def native
    render plain: show_path
  end

  def suffix
    render plain: params[:id]
  end

  def slash
    render plain: request.env['PATH_INFO']
  end

  def space
    render plain: request.env['PATH_INFO']
  end

  def unlocalized
    render plain: I18n.locale
  end
end
