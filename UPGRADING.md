# Upgrading Guide

See the [CHANGELOG.md](./CHANGELOG.md) for detailed information about what has changed between versions.

This guide is useful to figure out what you need to do between breaking changes.

## 16.2.0 to 17.0.0

`config.available_locales` now controls locale selection from request
parameters and hosts, not only route generation. Add every locale that must
be selectable to this configuration; values absent from
`I18n.available_locales` are ignored, while the default locale remains
included.

`RouteTranslator.available_locales` now returns a cached, frozen
`Set<Symbol>` rather than a newly allocated array. Update callers that mutate
the result to work with a copy instead. When changing locale configuration at
runtime, use block-form `RouteTranslator.config` or call `reset_config` to
rebuild the cache.

## 15.2.0 to 16.0.0

RouteTranslator 16 requires Ruby 3.2 or later and Rails 7.2 or later. Upgrade
both dependencies before upgrading the gem, or remain on RouteTranslator 15.2.0
if your application must support older versions.

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
