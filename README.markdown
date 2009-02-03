TranslateRoutes
===============

This Rails plugin provides a simple way to translate your URLs to any number of languages, even on a fully working application.  

It works fine with all kind of routing definitions, including RESTful and named routes.  
**Your current code will remain untouched**: your current routing code, helpers and links will be translated transparently.  
(Un)installing it is a very clean and simple process, so why don't you give it a chance? ;)

Quick start
-----------

Let's start with a tiny example. Of course you need to define your routes first, e.g:

    ActionController::Routing::Routes.draw do |map| 
      map.contact 'contact', :controller => 'contact', :action => 'index'
    end

1) Download the plugin to your app's `/vendor/plugins` directory.

2) Write your translations on a standard YAML file (e.g: i18n-routes.yml), including the locales and it translations pairs:

    es-ES:
      contact: contacto


3) Append a line to your routes.rb file to activate the translations. If you loaded the translations file with
your other I18n translations files, the line will be:

    ActionController::Routing::Translator.i18n('es')
  
and if you want to keep the file separated (e.g: config/i18n-routes.yml), the line to append is:

	ActionController::Routing::Translator.translate_from_file('config','i18n-routes.yml')

You can see it working by executing `rake routes` on the shell:


    contact_es_es_path /es-ES/contacto {:locale=>"es-ES", :controller=>"contact", :action=>"index"}
    contact_en_us_path /contact        {:locale=>"'en'", :controller=>"contact", :action=>"index"}


As we can see, a new spanish route has been setted up and a `locale` parameter has been added to the routes.

4) Include this filter in your ApplicationController:

    before_filter :set_locale_from_url

Now your application recognizes the different routes and sets the `I18n.locale` value on your controllers, 
but what about the routes generation? As you can see on the previous `rake routes` execution, the 
`contact_es_es_path` and `contact_en_us_path` routing helpers have been generated and are 
available in your controllers and views. Additionally, a `contact_path` helper has been generated, which 
generates the routes according to the current request's locale. This way your link 

This means that if you use named routes **you don't need to modify your application links** because the routing helpers are automatically adapted to the current locale.

5) Hey, but what about my tests?

Of course, your functional and integration testing involves some requests. 
The plugin includes some code to add a default locale parameter so they can remain untouched.
Append it to your `test_helper` and it will be applied.

An special case: root route ("/") with `prefix_on_default_locale`
-----------------------------------------------------------------

The root route ("/" route) is handled differently depending on the `prefix_on_default_locale` configuration option. If `prefix_on_default_locale` is set to true, the root route remains untouched and all localized versions of this root route are generated.

This is better explained with an example.  Given the following single route definition on config/routes.rb:

    map.root :controller => "home", :action => "index"

Without translate_routes the generated routes are:

    root  / {:controller=>"home", :action=>"index"}

With translate_routes and `prefix_on_default_locale` set to `false` the routes are:

    root_es  /   {:action=>"index", :controller=>"home", :locale=>"es"}
    root_en  /en {:action=>"index", :controller=>"home", :locale=>"en"}

And finally with translate_routes and `prefix_on_default_locale` set to `true` the routes are:

    root     /   {:action=>"index", :controller=>"home"}
    root_es  /es {:action=>"index", :controller=>"home", :locale=>"es"}
    root_en  /en {:action=>"index", :controller=>"home", :locale=>"en"}

It's important to note that in this last case the original root route does not set the `locale` param.  This allows controller code to distinguish the "unlocalized root" path ("/") from the "localized root" paths ("/es", "/en") and to redirect the user to a suitable default locale from the unlocalized root.  The following example shows how to do it with the excellent [`http_accept_language` plugin](http://github.com/iain/http_accept_language):

    def index
      available_locales = [ "es", "en"]
      unless params[ :locale]
        # if the locale is not specified in the URL we are in the unlocalized root path
        # we find the first available locale from the user agent's Accept-Language header
        request.user_preferred_languages.each do |locale|
          if available_locales.include?( locale)
            redirect_to :locale => locale   # we found one, redirect and finish
            return
          end
        end

        # no suitable locale found, redirect to the default one
        redirect_to :locale => I18n.default_locale
        return
      end

      # locale is set, handle the action as usual
      ...
    end

Suggestions, bug reports, questions
-----------------------------------
Feedback, questions and comments will be always welcome at raul@murciano.net

Credits
-------
* Main development:
  * Raul Murciano <http://raul.murciano.net> - code  
  * Domestika INTERNET S.L <http://domestika.org> - incredible support, really nice people to work with!  

* Contributors:
  * Aitor Garay-Romero
  * hoelmer (sorry mate, I can't find your real name)

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