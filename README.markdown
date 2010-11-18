TranslateRoutes
===============

This branch works with Rails 3.x, you can find branches for Rails [2.1.x](http://github.com/raul/translate_routes/tree/rails2.1), [2.2.x](http://github.com/raul/translate_routes/tree/rails2.2) and [2.3.x](http://github.com/raul/translate_routes/tree/rails2.3)

This Rails plugin provides a simple way to translate your URLs to any number of languages, even on a fully working application.

It works fine with all kind of routing definitions, including RESTful and named routes.
**Your current code will remain untouched**: your current routing code, helpers and links will be translated transparently - even in your tests.
(Un)installing it is a very clean and simple process, so why don't you give it a chance? ;)

Installation
------------
Add translate_routes to your `Gemfile`:
  
    gem 'translate_routes'
    
And let bundle do the rest:

    bundle install

Quick Start
-----------

1) Let's imagine you have this `routes.rb` file:

    TranslateRoutesApp::Application.routes.draw do
      match 'contact' => 'contact#index'
    end

You can see the available routes with the `rake routes` task:


    contact  /contact(.:format) {:controller=>"contact", :action=>"index"}

2) Now write your translations on a standard YAML file (e.g: in `/config/i18n-routes.yml`), including all the locales and their translations pairs:

    en:
      # you can leave empty locales, for example the default one
    es:
      contact: contacto

3) Append this line in your `routes.rb` file to activate the translations specifying the path of the translations file:

    ActionDispatch::Routing::Translator.translate_from_file('config','i18n-routes.yml')

4) Execute `rake routes` to see the new routes:

    contact_es  /es/contacto(.:format) {:controller=>"contact", :action=>"index"}
    contact_en  /contact(.:format)     {:controller=>"contact", :action=>"index"}

5) Include this filter in your ApplicationController:

    before_filter :set_locale_from_url

Now your application recognizes the different routes and sets the `I18n.locale` value in your controllers,
but what about the routes generation? As you can see on the previous `rake routes` execution, the
`contact_es_es_path` and `contact_en_us_path` routing helpers have been generated and are
available in your controllers and views. Additionally, a `contact_path` helper has been generated, which
generates the routes according to the current request's locale. This way your link

This means that if you use named routes **you don't need to modify your application links** because the routing helpers are automatically adapted to the current locale.

6) Hey, but what about my tests?

Of course, your functional and integration testing involves some requests.
The plugin includes some code to add a default locale parameter so they can remain untouched.
Append it to your `test_helper` and it will be applied.

Documentation
-------------
You can find additional information in [the translate_routes' wiki](http://wiki.github.com/raul/translate_routes).

Questions, suggestions, bug reports...
--------------------------------------
Feedback, questions and comments will be always welcome at raul@murciano.net

Credits
-------
* Main development:
  * Raul Murciano <http://raul.murciano.net> - code
  * Domestika INTERNET S.L <http://domestika.org> - incredible support, really nice people to work with!

* Contributors:
  * [Aitor Garay-Romero](http://github.com/aitorgr)
  * [Christian Hølmer](http://github.com/hoelmer)
  * Nico Ritsche
  * [Cedric Darricau](http://github.com/devsigner)
  * [Olivier Gonzalez](http://github.com/gonzoyumo)
  * [Kristian Mandrup](http://github.com/kristianmandrup)
  * [Pieter Visser](http://github.com/pietervisser)
  * [Marian Theisen](http://github.com/cice)
  * [Enric Lluelles](http://github.com/enriclluelles)
  * [Jaime Iniesta](http://github.com/jaimeiniesta)

Rails routing resources
-----------------------
* David Black's 'Rails Routing' ebook rocks! - 'Ruby for Rails' too, BTW.
* Obie Fernandez's 'The Rails Way' - the definitive RoR reference, great work Obie!
* As a part of the impressive Rails Guides set there is an [awesome document about rails routing](http://guides.rails.info/routing_outside_in.html) by Mike Gunderloy:


License
-------
    Copyright (c) 2007 Released under the MIT license (see MIT-LICENSE)
    Raul Murciano <http://raul.murciano.net>
    Domestika INTERNET S.L. <http://domestika.org>