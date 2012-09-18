RouteTranslator
===============

[![Build Status](https://secure.travis-ci.org/enriclluelles/route_translator.png)](http://travis-ci.org/enriclluelles/route_translator)

RouteTranslator is a gem to allow you to manage the translations of your
app routes with a simple dictionary format

It started as a fork of the awesome [translate_routes](https://github.com/raul/translate_routes) plugin by [Raúl Murciano](https://github.com/raul) and then I made changes as I needed until it became the actual code

Right now it works with all the different flavours of rails3 (3.0, 3.1, 3.2) but I'm planning to make it compatible with rails 2.3 too. I'll see how it goes


Quick Start
-----------

1. If you have this `routes.rb` file originally:

  ```ruby
      MyApp::Application.routes.draw do

        namespace :admin do
          resources :cars
        end

        resources :cars
      end
  ```

    the output of `rake routes.rb` would be this:

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

2. Add the gem to your `Gemfile`:

    ```ruby
      gem 'route_translator'
    ```

   And execute `bundle install`

3. Wrap the groups of routes that you want to translate inside a
   `localized` block:

   ```ruby
      MyApp::Application.routes.draw do

        namespace :admin do
          resources :cars
        end

        localized do
          resources :cars
        end
      end

      MyApp::Application.routes.translate_from_file
      # You may pass the file path as a param here,
      # default is config/i18n-routes.yml
   ```

    And add the translations to a YAML file, for example
`config/i18n-routes.yml`:

    ```yaml
    es:
      cars: coches
      new: nuevo
    fr:
      cars: voitures
      new: nouveau
    ```

4. Your routes are translated! Here's the output of your `rake routes` now:

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

    Note that only the routes inside a `localized` block are translated

5. Include this filter in your `ApplicationController` if you want to set
   the I18n.locale value from the value set in the route

    ```ruby
        before_filter :set_locale_from_url
    ```

Configuration
-------------

To configure RouteTranslator via rails use `config.route_translator` in your
application and/or environment files to set configuration properties that will
be passed to RouteTranslator.

### Example

```ruby
MyProject::Application.configure do
  config.route_translator.force_locale = true
end
```

### Available Configurations

* **force_locale** - Set this options to `true` to force the locale to be
  added to all generated route paths, even for the default locale.
  Defaults to `false`.
* **generate_unlocalized_routes** - Set this option to `true` to add
  translated routes without deleting original unlocalized versions.
  Autosets `force_locale=true`. Defaults to `false`.

Contributing
------------

Bring it! Send me a pull request, don't worry about styling or small
details, I'm open to discussion
