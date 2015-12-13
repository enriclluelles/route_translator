class DummyController < ActionController::Base

  def dummy
    render :text => I18n.locale
  end

  def show
    # Pass
  end

  def optional
    # Pass
  end

end
