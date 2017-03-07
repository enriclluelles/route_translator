class DummyController < ActionController::Base
  def dummy
    render plain: I18n.locale
  end

  def native
    render plain: show_path
  end

  def suffix
    render plain: params[:id]
  end

  def engine_es
    render plain: blorgh_es.posts_path
  end

  def engine
    render plain: blorgh.posts_path
  end
end
