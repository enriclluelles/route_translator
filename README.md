# RouteTranslator

[![Gem Version](https://badge.fury.io/rb/route_translator.svg)](https://badge.fury.io/rb/route_translator)
[![SemVer](https://api.dependabot.com/badges/compatibility_score?dependency-name=route_translator&package-manager=bundler&version-scheme=semver)](https://dependabot.com/compatibility-score.html?dependency-name=route_translator&package-manager=bundler&version-scheme=semver)
[![Build Status](https://travis-ci.org/enriclluelles/route_translator.svg?branch=master)](https://travis-ci.org/enriclluelles/route_translator)
[![Maintainability](https://api.codeclimate.com/v1/badges/1c369ce6147724b353fc/maintainability)](https://codeclimate.com/github/enriclluelles/route_translator/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/enriclluelles/route_translator/badge.svg?branch=master)](https://coveralls.io/github/enriclluelles/route_translator?branch=master)

RouteTranslator is a gem to allow you to manage the translations of your app routes with a simple dictionary format.

It started as a fork of the awesome [translate_routes](https://github.com/raul/translate_routes) plugin by [Raúl Murciano](https://github.com/raul).

Right now it works with Rails 5.x and Rails 6.x



## Quick Start

1.  If you have this `routes.rb` file originally:

    ```ruby
    Rails.application.routes.draw do
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
    Rails.application.routes.draw do
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
            Prefix Verb   URI Pattern                     Controller#Action
        admin_cars GET    /admin/cars(.:format)           admin/cars#index
                   POST   /admin/cars(.:format)           admin/cars#create
     new_admin_car GET    /admin/cars/new(.:format)       admin/cars#new
    edit_admin_car GET    /admin/cars/:id/edit(.:format)  admin/cars#edit
         admin_car GET    /admin/cars/:id(.:format)       admin/cars#show
                   PATCH  /admin/cars/:id(.:format)       admin/cars#update
                   PUT    /admin/cars/:id(.:format)       admin/cars#update
                   DELETE /admin/cars/:id(.:format)       admin/cars#destroy
           cars_fr GET    /fr/voitures(.:format)          cars#index {:locale=>"fr"}
           cars_es GET    /es/coches(.:format)            cars#index {:locale=>"es"}
           cars_en GET    /cars(.:format)                 cars#index {:locale=>"en"}
                   POST   /fr/voitures(.:format)          cars#create {:locale=>"fr"}
                   POST   /es/coches(.:format)            cars#create {:locale=>"es"}
                   POST   /cars(.:format)                 cars#create {:locale=>"en"}
        new_car_fr GET    /fr/voitures/nouveau(.:format)  cars#new {:locale=>"fr"}
        new_car_es GET    /es/coches/nuevo(.:format)      cars#new {:locale=>"es"}
        new_car_en GET    /cars/new(.:format)             cars#new {:locale=>"en"}
       edit_car_fr GET    /fr/voitures/:id/edit(.:format) cars#edit {:locale=>"fr"}
       edit_car_es GET    /es/coches/:id/edit(.:format)   cars#edit {:locale=>"es"}
       edit_car_en GET    /cars/:id/edit(.:format)        cars#edit {:locale=>"en"}
            car_fr GET    /fr/voitures/:id(.:format)      cars#show {:locale=>"fr"}
            car_es GET    /es/coches/:id(.:format)        cars#show {:locale=>"es"}
            car_en GET    /cars/:id(.:format)             cars#show {:locale=>"en"}
                   PATCH  /fr/voitures/:id(.:format)      cars#update {:locale=>"fr"}
                   PATCH  /es/coches/:id(.:format)        cars#update {:locale=>"es"}
                   PATCH  /cars/:id(.:format)             cars#update {:locale=>"en"}
                   PUT    /fr/voitures/:id(.:format)      cars#update {:locale=>"fr"}
                   PUT    /es/coches/:id(.:format)        cars#update {:locale=>"es"}
                   PUT    /cars/:id(.:format)             cars#update {:locale=>"en"}
                   DELETE /fr/voitures/:id(.:format)      cars#destroy {:locale=>"fr"}
                   DELETE /es/coches/:id(.:format)        cars#destroy {:locale=>"es"}
                   DELETE /cars/:id(.:format)             cars#destroy {:locale=>"en"}
        pricing_fr GET    /fr/prix(.:format)              home#pricing {:locale=>"fr"}
        pricing_es GET    /es/precios(.:format)           home#pricing {:locale=>"es"}
        pricing_en GET    /pricing(.:format)              home#pricing {:locale=>"en"}
    ```

    Note that only the routes inside a `localized` block are translated.

    In :development environment, I18n is configured by default to not use fallback language.
    When a translation is missing, it uses the translation key last segment as fallback (`cars` and `new` in this example).

    In :production environment, you should either set `config.i18n.fallbacks = false` or set up translations for your routes in every languages.

5.  If you want to set `I18n.locale` from the url parameter locale, add
    the following line in your `ApplicationController` or in the controllers
    that have translated content:

    ```ruby
    around_action :set_locale_from_url
    ```

    Note: you might be tempted to use `before_action` instead of `around_action`: just don't. That could lead to [thread-related issues](https://github.com/enriclluelles/route_translator/issues/44).


### Changing the Language

To change the language and reload the appropriate route while staying on the same page, use the following code snippet:

```ruby
link_to url_for(locale: 'es'), hreflang: 'es', rel: 'alternate'
```

Although locales are stored by Rails as a symbol (`:es`), when linking to a page in a different locale you need to use a string (`'es'`). Otherwise, instead of a namespaced route (`/es/my-route`) you will get a parameterized route (`/my-route?locale=es`).

If the page contains a localized slug, the above snippet does not work and a custom implementation is neede.

More information at [Generating translated URLs](https://github.com/enriclluelles/route_translator/wiki/Generating-translated-URLs)


### Namespaces

You can translate a namespace route by either its `name` or `path` option:

1.  Wrap the namespaces that you want to translate inside a `localized` block:

    ```ruby
    Rails.application.routes.draw do
      localized do
        namespace :admin do
          resources :cars, only: :index
        end

        namespace :sold_cars, path: :sold do
          resources :cars, only: :index
        end
      end
    end
    ```

    And add the translations to your locale files, for example:

    ```yml
    es:
      routes:
        admin: administrador
        cars: coches
        new: nuevo
        pricing: precios
        sold: vendidos
    fr:
      routes:
        admin: administrateur
        cars: voitures
        new: nouveau
        pricing: prix
        sold: vendues
    ```

4.  Your namespaces are translated! Here's the output of your `rake routes` now:

    ```
               Prefix Verb URI Pattern                           Controller#Action
        admin_cars_fr GET  /fr/administrateur/voitures(.:format) admin/cars#index {:locale=>"fr"}
        admin_cars_es GET  /es/administrador/coches(.:format)    admin/cars#index {:locale=>"es"}
        admin_cars_en GET  /admin/cars(.:format)                 admin/cars#index {:locale=>"en"}
    sold_cars_cars_fr GET  /fr/vendues/voitures(.:format)        sold_cars/cars#index {:locale=>"fr"}
    sold_cars_cars_es GET  /es/vendidos/coches(.:format)         sold_cars/cars#index {:locale=>"es"}
    sold_cars_cars_en GET  /sold/cars(.:format)                  sold_cars/cars#index {:locale=>"en"}
    ```


### Inflections

At the moment inflections are not supported, but you can use the following workaround:

```ruby
localized do
  resources :categories, path_names: { new: 'new_category' }
end
```

```yml
en:
  routes:
    category: category
    new_category: new

es:
  routes:
    category: categoria
    new_category: nueva
```

```
          Prefix Verb   URI Pattern                       Controller#Action
   categories_es GET    /es/categorias(.:format)          categories#index {:locale=>"es"}
   categories_en GET    /categories(.:format)             categories#index {:locale=>"en"}
                 POST   /es/categorias(.:format)          categories#create {:locale=>"es"}
                 POST   /categories(.:format)             categories#create {:locale=>"en"}
 new_category_es GET    /es/categorias/nueva(.:format)    categories#new {:locale=>"es"}
 new_category_en GET    /categories/new(.:format)         categories#new {:locale=>"en"}
edit_category_es GET    /es/categorias/:id/edit(.:format) categories#edit {:locale=>"es"}
edit_category_en GET    /categories/:id/edit(.:format)    categories#edit {:locale=>"en"}
     category_es GET    /es/categorias/:id(.:format)      categories#show {:locale=>"es"}
     category_en GET    /categories/:id(.:format)         categories#show {:locale=>"en"}
                 PATCH  /es/categorias/:id(.:format)      categories#update {:locale=>"es"}
                 PATCH  /categories/:id(.:format)         categories#update {:locale=>"en"}
                 PUT    /es/categorias/:id(.:format)      categories#update {:locale=>"es"}
                 PUT    /categories/:id(.:format)         categories#update {:locale=>"en"}
                 DELETE /es/categorias/:id(.:format)      categories#destroy {:locale=>"es"}
                 DELETE /categories/:id(.:format)         categories#destroy {:locale=>"en"}
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

| Option | Description | Default |
| ------ | ----------- |-------- |
| `available_locales` | Limits the locales for which URLs should be generated for. Accepts an array of strings or symbols. When empty, translations will be generated for all `I18n.available_locales` | `[]` |
| `disable_fallback` | Creates routes only for locales that have translations. For example, if we have `/examples` and a translation is not provided for `es`, the route helper of `examples_es` will not be created. Useful when one uses this with a locale route constraint, so non-`es` routes can return a `404` on a Spanish website | `false` |
| `force_locale` |  Forces the locale to be added to all generated route paths, even for the default locale |  `false` |
| `generate_unlocalized_routes` | Adds translated routes without deleting original unlocalized versions. **Note:** Autosets `force_locale` to `true` | `false` |
| `generate_unnamed_unlocalized_routes` | Adds the behavior of `force_locale`, but with a named default route which behaves as if `generate_unlocalized_routes` was `true`. `root_path` will redirect to `/en` or `/es`, depending on the value of `I18n.locale` | `false` |
| `hide_locale` | Forces the locale to be hidden on generated route paths | `false` |
| `host_locales` | Sets `I18n.locale` based on `request.host`. Useful for apps accepting requests from more than one domain. See below for more details | `{}` |
| `locale_param_key` | The param key used to set the locale to the newly generated routes | `:locale` |
| `locale_segment_proc` | The locale segment of the url will by default be `locale.to_s.downcase`. You can supply your own mechanism via a Proc that takes `locale` as an argument, e.g. `->(locale) { locale.to_s.upcase }` | `false` |


### Host-based Locale

If you have an application serving requests from more than one domain, you might want to set `I18n.locale` dynamically based on which domain the request is coming from.

The `host_locales` option is a hash mapping hosts to locales, with full wildcard support to allow matching multiple domains/subdomains/tlds.
Host matching is case insensitive.

When a request hits your app from a domain matching one of the wild-card matchers defined in `host_locales`, the locale will be set to the specified locale.
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

If `host_locales` option is set, the following options will be forced:

```ruby
@config.force_locale                        = false
@config.generate_unlocalized_routes         = false
@config.generate_unnamed_unlocalized_routes = false
@config.hide_locale                         = true
```

This is to avoid odd behaviour brought about by route conflicts and because `host_locales` forces and hides the host-locale dynamically.

NOTE: locale from parameters has priority over the one from hosts.


### Translations for similar routes with different namespaces

If you have routes that (partially) share names in one locale, but must be translated differently in another locale, for example:

```ruby
get 'people/favourites', to: 'people/products#favourites'
get 'favourites',        to: 'products#favourites'
```

Then it is possible to provide different translations for common parts of those routes by
scoping translations by a controller's namespace:

```yml
es:
  routes:
    favourites: favoritos
    controllers:
      people:
        products:
          favourites: fans
```

Routes will be translated as in:

```
people_products_favourites_es GET  /people/products/fans(.:format)       people/products#favourites {:locale=>"es"}
       products_favourites_es GET  /products/favoritos(.:format)         products#favourites {:locale=>"es"}
```

The gem will lookup translations under `controllers` scope first and then lookup translations under `routes` scope.


### Change locale parameter position in the path

If you need complex routing as `/:country/:locale/path/to/some/pages`, you can specify the position of your locale parameter in the following way:

```rb
scope ':country/:locale' do
  localized do
    root to: 'content#homepage'
  end
end
```



## Testing
Testing your controllers with routes-translator is easy, just add a locale parameter as `String` for your localized routes. Otherwise, an `ActionController::UrlGenerationError` will raise.

```ruby
describe 'GET index' do
  it 'should respond with success' do
    # Remember to pass the locale param as String
    get :index, locale: 'fr'

    expect(response).to be_success
  end
end
```



## Contributing

Please read through our [contributing guidelines](CONTRIBUTING.md). Included are directions for opening issues, coding standards, and notes on development.

More over, if your pull request contains patches or features, you must include relevant unit tests.
