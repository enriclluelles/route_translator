---
name: Bug report
about: Create a report to help us improve
title: ''
labels: ''
assignees: ''

---

### Steps to reproduce*

### Expected behavior*
_Tell us what should happen_

### Actual behavior*
_Tell us what happens instead_

### System configuration*
**Rails version**:
_Replace with output of `rails -v`_
**Ruby version**:
_Replace with output of `bundle exec rails -v`_
**Route Translator version**:
_Replace with output of `cat Gemfile.lock | grep route_translator`_

### I18n configuration*

```rb
# Replace this comment with your I18n configuration
# taken from config/application.rb
```

### Route Translator initializier

Source of: `config/initializers/route_translator.rb`

```rb
# Replace this comment with the source code
# of config/initializers/route_translator.rb
```

### Source code of routes.rb*

Source of: `config/routes.rb`

```rb
# Replace this comment with the relevant
# source code of config/routes.rb
```

### Locale `.yml` files*

Source of `config/locales/xx.yml`

```yml
# Replace this comment with the relevant
# source code of config/locales/xx.yml
```

Source of `config/locales/yy.yml`

```yml
# Replace this comment with the relevant
# source code of config/locales/xx.yml
```

_Add more locales if needed_

### Output of `rails routes`*

Result of `bundle exec rails routes`:

```
# Replace this comment with the output
# of `bundle exec rails routes`
```

### Repository demostrating the issue
Debugging Route Translator issues is a time consuming task. If you want to speed
up things, please provide a link to a repository showing the issue.

---

**\*** Failure to include this requirement may result in the issue being closed.
