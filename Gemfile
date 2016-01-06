# Bower packages
source 'https://rails-assets.org' do
  # Promise library
  gem 'rails-assets-bluebird'

  # Style framework
  gem 'rails-assets-bootstrap'

  # Rails JS helpers
  gem 'rails-assets-jquery-ujs'

  # JS initialization framework
  gem 'rails-assets-regulator'

  # Utilities
  gem 'rails-assets-underscore'
  gem 'rails-assets-underscore.string'
end

source 'https://rubygems.org'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Authentication
gem 'devise'

# Incoming emails
gem 'griddler'
gem 'griddler-sendgrid'

# HAML templates
gem 'haml-rails', '~> 0.9'

# Postgres
gem 'pg'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Default environment variable config
  gem 'dotenv-rails'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Factories
  gem 'factory_girl'

  # Allow context/should blocks in tests
  gem 'shoulda-context'

  # Run individual tests using rake matchers
  gem 'single_test'
end

