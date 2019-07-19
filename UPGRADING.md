# Upgrading Guide

See the [CHANGELOG.md](./CHANGELOG.md) for detailed information about what has changed between versions.

This guide is useful to figure out what you need to do between breaking changes.

## 6.0.0 to 7.0.0

### Do not set locale from url by default

Route Translator 7.0 does not add `around_action :set_locale_from_url` to
`ActionController::Base` anymore.

You can include it in your `ApplicationController` or in the controllers
that require the `I18n.locale` being set from the url parameters.
