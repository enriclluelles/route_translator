# frozen_string_literal: true

# Use this setup block to configure all options available in RouteTranslator.
RouteTranslator.config do |config|
  # Limit the locales for which URLs should be generated for. Accepts an array
  # of strings or symbols. When empty, translations will be generated for all
  # `I18n.available_locales`
  # config.available_locales = []

  # Create routes only for locales that have translations. For example, if
  # we have `/examples` and a translation is not provided for `es`, the route
  # helper of `examples_es` will not be created. Useful when one uses this with
  # a locale route constraint, so non-es routes can return a `404` on a
  # Spanish website
  # config.disable_fallback = false

  # Force the locale to be added to all generated route paths, even for the
  # default locale
  # config.force_locale = false

  # Add translated routes without deleting original unlocalized versions.
  # Note: Autosets `force_locale` to `true`
  # config.generate_unlocalized_routes = false

  # Add the behavior of `force_locale`, but with a named default route which
  # behaves as if `generate_unlocalized_routes` was `true`. `root_path` will
  # redirect to `/en` or `/es`, depending on the value of `I18n.locale`
  # config.generate_unnamed_unlocalized_routes = false

  # Force the locale to be hidden on generated route paths
  # config.hide_locale = false

  # Set `I18n.locale` based on `request.host`. Useful for apps accepting
  # requests from more than one domain. See Readme for more details
  # config.host_locales = {}

  # The param key used to set the locale to the newly generated routes
  # config.locale_param_key = :locale

  # The locale segment of the url will by default be `locale.to_s.downcase`.
  # You can supply your own mechanism via a Proc that takes `locale`
  # as an argument, e.g. `->(locale) { locale.to_s.upcase }`
  # config.locale_segment_proc = false
end
