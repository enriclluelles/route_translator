# Changelog

## 5.1.0 (2017-01-24)

* Add: Translate controllers with namespaces (#120)
* Update development dependencies

## 5.0.6 (2017-01-17)

* Test against Ruby 2.4.0
* Update copyright in LICENSE
* Improve Translator method
* Minor improvements

## 5.0.5 (2016-12-15)

* Fix generated prefix to localized one (#123)
* Improve Mapper's monkey patch

## 5.0.4 (2016-11-11)

* Retain value of options_constraints if callable

## 5.0.3 (2016-11-01)

* Fix issue with callable constraints
* Update development dependencies

## 5.0.2 (2016-08-02)

* Replace around_filter with around_action
* Update development dependencies

## 5.0.1 (2016-07-14)

* Add private keyword in Segment module
* Update development dependencies

## 5.0.0 (2016-07-01)

* Rails 5 compatibility

## 4.4.0 (2016-07-01)

* Support custom locale path segments, i.e. /uk/en/widgets
* Using AS::Concern instead of monkey patching ActionController
* Update development dependencies

## 4.3.0 (2016-03-03)

* Refactor translator module

## 4.2.5 (2016-02-11)

* Fix: Generate correct route when a segment is preceded by a dot (#132)
* Improve TestCase helpers test

## 4.2.4 (2016-02-04)

* Change how helpers are loaded in TestCase
* Update dependencies

## 4.2.3 (2016-01-15)

* Minor tweaks

## 4.2.2 (2015-12-16)

* Fix: native path generation with host_locale (#95)
* Improve tests

## 4.2.1 (2015-12-15)

* Fix: gemspec

## 4.2.0 (2015-12-15)

* Style update to match RuboCop recommandations
* Fix: permit named_params with suffix (#116)
* Fix: optional parameters with prefix (#118)
