# frozen_string_literal: true

module Account
  class FooController < ActionController::Base
    around_action :set_locale_from_url

    def account_root
      render plain: "works: #{I18n.locale}"
    end
  end
end
