# Changelog

## 14.1.1 / 2023-12-19

* [BUGFIX] Fix memory leak in development mode ([#301](https://github.com/enriclluelles/route_translator/pull/301))
* [ENHANCEMENT] Update development dependencies

## 14.1.0 / 2023-10-05

* [FEATURE] Rails 7.1 compatibility

## 14.0.1 / 2023-09-03

* [BUGFIX] Fix eager load on booting ([#296](https://github.com/enriclluelles/route_translator/issues/296))

## 14.0.0 / 2023-09-02

* [FEATURE] BREAKING CHANGE: Force standard nested separator (Upgrade guide at [#285](https://github.com/enriclluelles/route_translator/pull/285))
* [FEATURE] Drop Ruby 2.6 compatibility
* [FEATURE] Drop Rails < 6.1 compatibility
* [FEATURE] Add initializer generator
* [ENHANCEMENT] Update development dependencies

## 13.2.1 / 2023-07-28

* [BUGFIX] Fix deprecation on Rails Edge

## 13.2.0 / 2023-07-28

* [FEATURE] Add option for standard nested separator ([#285](https://github.com/enriclluelles/route_translator/pull/285))
* [ENHANCEMENT] Update development dependencies

## 13.1.1 / 2023-07-01

* [ENHANCEMENT] Better integration with ActionController::TestCase
* [ENHANCEMENT] Remove Rails 5.1 code
* [ENHANCEMENT] Update development dependencies

## 13.1.0 / 2022-12-26

* [ENHANCEMENT] Test against Ruby 3.1 and Ruby 3.2
* [ENHANCEMENT] Better integration with ActionController::TestCase

## 13.0.0 / 2022-09-01

* [FEATURE] Replace Addressable gem with `URI::DEFAULT_PARSER` ([#268](https://github.com/enriclluelles/route_translator/pull/234))
* [FEATURE] Drop Ruby 2.5 support ([#270](https://github.com/enriclluelles/route_translator/pull/270))
* [ENHANCEMENT] Update development dependencies

## 12.1.0 / 2021-12-20

* [FEATURE] Add Rails 7.0 compatibility
* [ENHANCEMENT] Update development dependencies

## 12.0.0 / 2021-11-28

* [BUGFIX] Fix disable_fallback behavior ([#241](https://github.com/enriclluelles/route_translator/issues/241))
* [ENHANCEMENT] Update development dependencies

## 11.0.1 / 2021-11-15

* [ENHANCEMENT] Require MFA to publish gems
* [ENHANCEMENT] Update development dependencies

## 11.0.0 / 2021-09-26

* [FEATURE] Drop Ruby 2.4 support
* [FEATURE] Drop Rails 5.0 and 5.1 support
* [ENHANCEMENT] Update development dependencies

## 10.0.0 / 2021-01-16

* [BUGFIX] Verify host path consistency by default ([#91](https://github.com/enriclluelles/route_translator/issues/91), [#171](https://github.com/enriclluelles/route_translator/issues/171))
* [FEATURE] Remove the option to verify host path consistency
* [ENHANCEMENT] Avoid duplicate routes when using host_locales ([#87](https://github.com/enriclluelles/route_translator/issues/87), [#171](https://github.com/enriclluelles/route_translator/issues/171))
* [ENHANCEMENT] Test against Ruby 3.0.0
* [ENHANCEMENT] Update development dependencies

## 9.0.0 / 2020-11-07

* [ENHANCEMENT] Check for `empty?` instead of `any?` on available_locales array
* [ENHANCEMENT] Update development dependencies

## 8.2.1 / 2020-11-03

* [ENHANCEMENT] Fix deprecation with URI.parser ([#234](https://github.com/enriclluelles/route_translator/pull/234))

## 8.2.0 / 2020-11-03

* [FEATURE] Add Rails 6.1 compatibility
* [ENHANCEMENT] Update development dependencies

## 8.1.0 / 2020-08-10

* [FEATURE] Allow Ruby 3.0.0
* [ENHANCEMENT] Test against latest Ruby versions
* [ENHANCEMENT] Update development dependencies

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
