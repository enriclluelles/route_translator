# Changelog

## 6.0.0.alpha1 / 2017-07-23

* [BUGFIX] Verify host path consistency by default (#91)
* [FEATURE] Remove the option to verify host path consistency
* [ENHANCEMENT] Avoid duplicate routes when using host_locales (#87)
* [ENHANCEMENT] Update development dependencies

## 5.5.0 / 2017-06-29

* [FEATURE] Add an option to verify host path consistency (#167)
* [ENHANCHEMENT] Minor improvements

## 5.4.1 / 2017-06-01

* [ENHANCEMENT] Update development dependencies

## 5.4.0 / 2017-04-26

* [ENHANCEMENT] Rails 5.1 compatibility

## 5.3.1 / 2017-04-19

* [ENHANCEMENT] Test against latest Ruby versions
* [ENHANCEMENT] Update development dependencies

## 5.3.0 / 2017-03-21

* [FEATURE] Rails 5.1.0.rc1 compatibility

## 5.2.2 / 2017-03-21

* [BUGFIX] Lock maximum Rails version to 5.1.0.beta1

## 5.2.1 / 2017-03-09

* [ENHANCEMENT] Use Ruby 2.3's Frozen String Literal Pragma
* [ENHANCEMENT] Minor improvements

## 5.2.0 / 2017-03-08

* [FEATURE] Rails 5.1 compatibility
* [BUGFIX] Do not change I18n.default_locale
* [ENHANCEMENT] Cleanup test suite
* [ENHANCEMENT] Follow Vandamme's changelog conventions

## 5.1.0 / 2017-01-24

* [FEATURE] Translate controllers with namespaces (#120)
* [ENHANCEMENT] Update development dependencies

## 5.0.6 / 2017-01-17

* [PERFORMANCE] Improve Translator method
* [ENHANCEMENT] Test against Ruby 2.4.0
* [ENHANCEMENT] Update copyright in LICENSE
* [ENHANCEMENT] Minor improvements

## 5.0.5 / 2016-12-15

* [BUGFIX] Fix generated prefix to localized one (#123)
* [PERFORMANCE] Improve Mapper's monkey patch

## 5.0.4 / 2016-11-11

* [BUGFIX] Retain value of options_constraints if callable

## 5.0.3 / 2016-11-01

* [BUGFIX] Fix issue with callable constraints
* [ENHANCEMENT] Update development dependencies

## 5.0.2 / 2016-08-02

* [BUGFIX] Replace around_filter with around_action
* [ENHANCEMENT] Update development dependencies

## 5.0.1 / 2016-07-14

* [ENHANCEMENT] Add private keyword in Segment module
* [ENHANCEMENT] Update development dependencies

## 5.0.0 / 2016-07-01

* [FEATURE] Rails 5 compatibility

## 4.4.0 / 2016-07-01

* [FEATURE] Support custom locale path segments, i.e. /uk/en/widgets
* [ENHANCEMENT] Using AS::Concern instead of monkey patching ActionController
* [ENHANCEMENT] Update development dependencies

## 4.3.0 / 2016-03-03

* [PERFORMANCE] Refactor translator module

## 4.2.5 / 2016-02-11

* [BUGFIX] Generate correct route when a segment is preceded by a dot (#132)
* [ENHANCEMENT] Improve TestCase helpers test

## 4.2.4 / 2016-02-04

* [BUGFIX] Change how helpers are loaded in TestCase
* [ENHANCEMENT] Update dependencies

## 4.2.3 / 2016-01-15

* [PERFORMANCE] Minor tweaks

## 4.2.2 / 2015-12-16

* [BUGFIX] Fix native path generation with host_locale (#95)
* [ENHANCEMENT] Improve tests

## 4.2.1 / 2015-12-15

* [BUGFIX] Fix gemspec

## 4.2.0 / 2015-12-15

* [ENHANCEMENT] Style update to match RuboCop recommandations
* [BUGFIX] Permit named_params with suffix (#116)
* [BUGFIX] Fix optional parameters with prefix (#118)
