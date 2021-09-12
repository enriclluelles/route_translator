# frozen_string_literal: true

appraise 'rails-5.0' do
  gem 'rails', '~> 5.0.0'
end

appraise 'rails-5.1' do
  gem 'rails', '~> 5.1.0'
end

appraise 'rails-5.2' do
  gem 'rails', '~> 5.2.0'
end

appraise 'rails-6.0' do
  gem 'rails', '~> 6.0.0'

  # net-smtp has been removed from default gems in Ruby 3.1, but it is used
  # by the `mail` gem.
  # Remove when https://github.com/mikel/mail/pull/1439 is fixed
  gem 'net-smtp', require: false
end

appraise 'rails-6.1' do
  gem 'rails', '~> 6.1.0'

  # net-smtp has been removed from default gems in Ruby 3.1, but it is used
  # by the `mail` gem.
  # Remove when https://github.com/mikel/mail/pull/1439 is fixed
  gem 'net-smtp', require: false
end

appraise 'rails-edge' do
  gem 'rails', git: 'https://github.com/rails/rails.git', branch: 'main'

  # net-smtp has been removed from default gems in Ruby 3.1, but it is used
  # by the `mail` gem.
  # Remove when https://github.com/mikel/mail/pull/1439 is fixed
  gem 'net-smtp', require: false
end
