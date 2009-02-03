# monkeypatch I18n to get the available locales
# (not strictly needed to use translate_routes, but recommended anyway)
module I18n
  class << self
    def available_locales
      backend.available_locales
    end
  end

  module Backend
    class Simple
      def available_locales
        init_translations unless initialized?
        translations.keys
      end
    end
  end
end

# load translation files from RAILS_ROOT/locales
[:rb, :yml].each do |format|
  I18n.load_path = Dir[File.join(RAILS_ROOT, 'locales', '*.{rb,yml}') ]
end