
module RouteTranslator
  module I18nHelper

    def setup_i18n
      @i18n_backend   = I18n.backend
      @i18n_load_path = I18n.load_path

      I18n.locale     = I18n.default_locale
      I18n.backend    = I18n::Backend::Simple.new
      I18n.load_path  = [ File.expand_path('../../locales/routes.yml', __FILE__) ]

      I18n.reload!
    end

    def teardown_i18n
      I18n.backend    = @i18n_backend
      I18n.load_path  = @i18n_load_path

      I18n.reload!
    end

  end
end
