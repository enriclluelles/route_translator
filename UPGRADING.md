# Upgrading Guide

See the [CHANGELOG.md](./CHANGELOG.md) for detailed information about what has changed between versions.

This guide is useful to figure out what you need to do between breaking changes.

## 14.0.0 to 15.0.0

Route helpers now respect locale parameters (e.g., `posts_path(locale: "en")`) regardless
of host_locales configuration. Previously these were silently ignored.

Workarounds like `I18n.with_locale(:en) { posts_path }` can be replaced with
the now-working `posts_path(locale: "en")` syntax.

## 9.0.0 to 10.0.0

### Restrict host languages

Before Route Translator 10.0, the `host_locales` option allowed to use all
the languages on multiple hosts. This was causing duplication of routes as
described in [#171](https://github.com/enriclluelles/route_translator/issues/171).

Starting from 10.0, this use case is no longer supported out of the box and
requires a custom implementation.

Take a look at this Wiki page: [Use all languages on multiple hosts](https://github.com/enriclluelles/route_translator/wiki/Use-all-languages-on-multiple-hosts)

## 6.0.0 to 7.0.0

### Do not set locale from url by default

Route Translator 7.0 does not add `around_action :set_locale_from_url` to
`ActionController::Base` anymore.

You can include it in your `ApplicationController` or in the controllers
that require the `I18n.locale` being set from the url parameters.
