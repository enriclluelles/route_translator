class ApplicationController < ActionController::Base

  before_filter :set_locale_from_url

end
