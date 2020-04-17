# Changelog

## Unreleased

* [FEATURE] Add Rails > 6.0 compatibility

## 8.0.0 / 2020-04-17

* [FEATURE] Drop Ruby 2.3 support
* [ENHANCEMENT] Add gem metadata for RubyGems.org
* [ENHANCEMENT] Test against latest Ruby versions
* [ENHANCEMENT] Update development dependencies

## 7.1.2 / 2020-03-02

* [BUGFIX] Fix lazy load of action controller ([#206](https://github.com/enriclluelles/route_translator/pull/206))
* [ENHANCEMENT] Update development dependencies

## 7.1.1 / 2019-12-26

* [ENHANCEMENT] Minor improvements to configuration and tests

## 7.1.0 / 2019-12-26

* [ENHANCEMENT] Use Addressable gem for URI parsing
* [ENHANCEMENT] Fix Ruby 2.7 deprecations
* [ENHANCEMENT] Update dependencies

## 7.0.1 / 2019-10-14

* [BUGFIX] Fix missing dup on blocks ([#203](https://github.com/enriclluelles/route_translator/pull/203))
* [ENHANCEMENT] Test against latest Ruby versions
* [ENHANCEMENT] Update development dependencies

## 7.0.0 / 2019-07-30

* [FEATURE] Add Rails > 6.0.0.rc1 compatibility
* [FEATURE] Do not set locale from url by default
* [FEATURE] Do not raise InvalidLocale errors
* [ENHANCEMENT] Update development dependencies

## 6.0.0 / 2019-05-16

* [FEATURE] Drop Ruby 2.2 support
* [ENHANCEMENT] Update development dependencies

## 5.10.0 / 2019-04-25

* [FEATURE] Add Rails 6.0 compatibility
* [ENHANCEMENT] Test against latest Ruby versions

## 5.9.0 / 2019-03-14

* [FEATURE] Add Rails 6.0.0.beta3 compatibility
* [ENHANCEMENT] Test against latest Ruby versions

## 5.8.0 / 2019-03-02

* [FEATURE] Add Rails 6.0.0.beta2 compatibility
* [ENHANCEMENT] Update development dependencies

## 5.7.1 / 2019-02-03

* [ENHANCEMENT] Test against Ruby 2.6.1
* [ENHANCEMENT] Update development dependencies

## 5.7.0 / 2019-01-19

* [FEATURE] Add Rails 6.0.0.beta1 compatibility
* [ENHANCEMENT] Test against latest Ruby versions
* [ENHANCEMENT] Update development dependencies

## 5.6.4 / 2018-10-03

* [ENHANCEMENT] Update development dependencies

## 5.6.3 / 2018-06-07

* [ENHANCEMENT] Update development dependencies

## 5.6.2 / 2018-04-10

* [ENHANCEMENT] Test against Rails 5.2

## 5.6.1 / 2018-04-09

* [BUGFIX] Fix overriding ActionController::Live ([#183](https://github.com/enriclluelles/route_translator/pull/183))
* [ENHANCEMENT] Update development dependencies
* [ENHANCEMENT] Test against latest Ruby versions

## 5.6.0 / 2018-02-05

* [FEATURE] Add Rails 5.2 compatibility
* [ENHANCEMENT] Test against latest Ruby versions
* [ENHANCEMENT] Update development dependencies

## 5.5.3 / 2018-01-12

* [BUGFIX] Fix regression with translations containing spaces ([#181](https://github.com/enriclluelles/route_translator/issues/181))
* [ENHANCEMENT] Update development dependencies

## 5.5.2 / 2017-12-27

* [BUGFIX] Fix regression with translations containing slashes ([#179](https://github.com/enriclluelles/route_translator/pull/179))
* [ENHANCEMENT] Test against latest Ruby versions
* [ENHANCEMENT] Update development dependencies

## 5.5.1 / 2017-11-14

* [BUGFIX] Change spec to reflect Rails 5.1.3 change in url generation ([#172](https://github.com/enriclluelles/route_translator/issues/172))
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
