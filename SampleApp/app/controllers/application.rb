# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  before_filter :set_language
  
  private

  def set_language
    @lang = params[ActionController::Routing::Translator.lang_param_key] || ActionController::Routing::Translator.default_lang
    default_url_options ActionController::Routing::Translator => @lang

    Gibberish.current_language = @lang.to_sym # If you use the Gibberish plugin to translate strings
  end
  
end
