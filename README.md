# RouteTranslator

[![Gem Version](https://badge.fury.io/rb/route_translator.svg)](http://badge.fury.io/rb/route_translator)
[![Build Status](https://travis-ci.org/enriclluelles/route_translator.svg?branch=master)](https://travis-ci.org/enriclluelles/route_translator)
[![Dependency Status](https://gemnasium.com/enriclluelles/route_translator.svg)](https://gemnasium.com/enriclluelles/route_translator)
[![Code Climate](https://codeclimate.com/github/enriclluelles/route_translator/badges/gpa.svg)](https://codeclimate.com/github/enriclluelles/route_translator)
[![Coverage Status](https://coveralls.io/repos/github/enriclluelles/route_translator/badge.svg?branch=master)](https://coveralls.io/github/enriclluelles/route_translator?branch=master)

RouteTranslator is a gem to allow you to manage the translations of your app routes with a simple dictionary format.

It started as a fork of the awesome [translate_routes](https://github.com/raul/translate_routes) plugin by [Raúl Murciano](https://github.com/raul).

Right now it works with all the different flavours of rails 3-4 (3.2, 4.0, 4.1, 4.2).



## Quick Start

1.  If you have this `routes.rb` file originally:

    ```ruby
    MyApp::Application.routes.draw do

      namespace :admin do
        resources :cars
      end

      resources :cars
    end
    ```

    The output of `rake routes.rb` would be:

    ```
        admin_cars GET    /admin/cars(.:format)          admin/cars#index
                   POST   /admin/cars(.:format)          admin/cars#create
     new_admin_car GET    /admin/cars/new(.:format)      admin/cars#new
    edit_admin_car GET    /admin/cars/:id/edit(.:format) admin/cars#edit
         admin_car GET    /admin/cars/:id(.:format)      admin/cars#show
                   PUT    /admin/cars/:id(.:format)      admin/cars#update
                   DELETE /admin/cars/:id(.:format)      admin/cars#destroy
              cars GET    /cars(.:format)                cars#index
                   POST   /cars(.:format)                cars#create
           new_car GET    /cars/new(.:format)            cars#new
          edit_car GET    /cars/:id/edit(.:format)       cars#edit
               car GET    /cars/:id(.:format)            cars#show
                   PUT    /cars/:id(.:format)            cars#update
                   DELETE /cars/:id(.:format)            cars#destroy
    ```

2.  Add the gem to your `Gemfile`:

    ```ruby
    gem 'route_translator'
    ```

    And execute `bundle install`

3.  Wrap the groups of routes that you want to translate inside a `localized` block:

    ```ruby
    MyApp::Application.routes.draw do

      namespace :admin do
        resources :cars
      end

      localized do
        resources :cars

        get 'pricing', to: 'home#pricing', as: :pricing
      end
    end
    ```

    And add the translations to your locale files, for example:

    ```yml
    es:
      routes:
        cars: coches
        new: nuevo
        pricing: precios
    fr:
      routes:
        cars: voitures
        new: nouveau
        pricing: prix
    ```

4.  Your routes are translated! Here's the output of your `rake routes` now:

    ```
        admin_cars GET    /admin/cars(.:format)           admin/cars#index
                   POST   /admin/cars(.:format)           admin/cars#create
     new_admin_car GET    /admin/cars/new(.:format)       admin/cars#new
    edit_admin_car GET    /admin/cars/:id/edit(.:format)  admin/cars#edit
         admin_car GET    /admin/cars/:id(.:format)       admin/cars#show
                   PUT    /admin/cars/:id(.:format)       admin/cars#update
                   DELETE /admin/cars/:id(.:format)       admin/cars#destroy
           cars_en GET    /cars(.:format)                 cars#index {:locale=>"en"}
           cars_es GET    /es/coches(.:format)            cars#index {:locale=>"es"}
           cars_fr GET    /fr/voitures(.:format)          cars#index {:locale=>"fr"}
                   POST   /cars(.:format)                 cars#create {:locale=>"en"}
                   POST   /es/coches(.:format)            cars#create {:locale=>"es"}
                   POST   /fr/voitures(.:format)          cars#create {:locale=>"fr"}
        new_car_en GET    /cars/new(.:format)             cars#new {:locale=>"en"}
        new_car_es GET    /es/coches/nuevo(.:format)      cars#new {:locale=>"es"}
        new_car_fr GET    /fr/voitures/nouveau(.:format)  cars#new {:locale=>"fr"}
       edit_car_en GET    /cars/:id/edit(.:format)        cars#edit {:locale=>"en"}
       edit_car_es GET    /es/coches/:id/edit(.:format)   cars#edit {:locale=>"es"}
       edit_car_fr GET    /fr/voitures/:id/edit(.:format) cars#edit {:locale=>"fr"}
            car_en GET    /cars/:id(.:format)             cars#show {:locale=>"en"}
            car_es GET    /es/coches/:id(.:format)        cars#show {:locale=>"es"}
            car_fr GET    /fr/voitures/:id(.:format)      cars#show {:locale=>"fr"}
                   PUT    /cars/:id(.:format)             cars#update {:locale=>"en"}
                   PUT    /es/coches/:id(.:format)        cars#update {:locale=>"es"}
                   PUT    /fr/voitures/:id(.:format)      cars#update {:locale=>"fr"}
                   DELETE /cars/:id(.:format)             cars#destroy {:locale=>"en"}
                   DELETE /es/coches/:id(.:format)        cars#destroy {:locale=>"es"}
                   DELETE /fr/voitures/:id(.:format)      cars#destroy {:locale=>"fr"}
    ```

    Note that only the routes inside a `localized` block are translated.

    In :development environment, I18n is configured by default to not use fallback language.
    When a translation is missing, it uses the translation key last segment as fallback (`cars` and `new` in this example).

    In :production environment, you should either set `config.i18n.fallbacks = false` or set up translations for your routes in every languages.

5.  Your I18n.locale will be set up automatically from the url param when it's available.

    To disable it add this to your controller:

    ```ruby
    skip_around_filter :set_locale_from_url
    ```



## Configuration

You can configure RouteTranslator via an initializer or using the different environment config files.

```ruby
RouteTranslator.config do |config|
  config.force_locale = true
  config.locale_param_key = :my_locale
end
```



### Available Configurations

* **force_locale**
  Set this options to `true` to force the locale to be added to all generated route paths, even for the default locale.
  Defaults to `false`.
* **hide_locale**
  Set this options to `true` to force the locale to be hidden on generated route paths.
  Defaults to `false`.
* **generate_unlocalized_routes**
  Set this option to `true` to add translated routes without deleting original unlocalized versions.
  Autosets `force_locale=true`.
  Defaults to `false`.
* **generate_unnamed_unlocalized_routes**
  Set this option to `true` to add the behavior of **force_locale**, but with a named default route which behaves as if **generate_unlocalized_routes** was `true`.
  `root_path` will redirect to `/en` or `/es` depending on the value of `I18n.locale`.
  Defaults to `false`.
* **locale_param_key**
  The param key that will be used to set the locale to the newly generated routes.
  Defaults to `:locale`
* **host_locales**
  Optional hash to set `I18n.default_locale` based on `request.host`.
  Useful for apps accepting requests from more than one domain.
  See below for more details.
* **disable_fallback**
  Set this option to `true` to create only the routes for each locale that have translations.
  For example if we have `/examples` and a translation is not provided for ES, a route helper of `examples_es` will not be created.
  Defaults to `false`.
  Useful when one uses this with a locale route constraint, so non-ES routes can 404 on a Spanish website.
* **available_locales**
  Use this to limit the locales for which URLs should be generated for. Accepts an array of strings or symbols.


### Host-based Locale

If you have an application serving requests from more than one domain, you might want to set `I18n.default_locale` dynamically based on which domain the request is coming from.

The `host_locales` option is a hash mapping hosts to locales, with full wildcard support to allow matching multiple domains/subdomains/tlds.
Host matching is case insensitive.

When a request hits your app from a domain matching one of the wild-card matchers defined in `host_locales`, the default_locale will be set to the specified locale.
Unless you specified the `force_locale` configuration option to `true`, that locale will be hidden from routes (acting like a dynamic `hide_locale` option).

Here are a few examples of possible mappings:

```ruby
RouteTranslator.config.host_locales =
{                                # Matches:
  '*.es'                 => :es, # TLD:         ['domain.es', 'subdomain.domain.es', 'www.long.string.of.subdomains.es'] etc.
  'ru.wikipedia.*'       => :ru, # Subdomain:   ['ru.wikipedia.org', 'ru.wikipedia.net', 'ru.wikipedia.com'] etc.
  '*.subdomain.domain.*' => :ru, # Mixture:     ['subdomain.domain.org', 'www.subdomain.domain.net'] etc.
  'news.bbc.co.uk'       => :en, # Exact match: ['news.bbc.co.uk'] only
}
```

In the case of a host matching more than once, the order in which the matchers are defined will be taken into account, like so:

```ruby
RouteTranslator.config.host_locales = { 'russia.*' => :ru, '*.com'    => :en } # 'russia.com' will have locale :ru
RouteTranslator.config.host_locales = { '*.com'    => :en, 'russia.*' => :ru } # 'russia.com' will have locale :en
```

If `host_locales` option is set, the following options will be forced (even if you set to true):

```ruby
@config.generate_unlocalized_routes         = false
@config.generate_unnamed_unlocalized_routes = false
@config.force_locale                        = false
@config.hide_locale                         = false
```

This is to avoid odd behaviour brought about by route conflicts and because `host_locales` forces and hides the host-locale dynamically.



## Contributing

Please read through our [contributing guidelines](CONTRIBUTING.md). Included are directions for opening issues, coding standards, and notes on development.

More over, if your pull request contains patches or features, you must include relevant unit tests.
