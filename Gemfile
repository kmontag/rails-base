# Bower packages
source 'https://rails-assets.org' do
  # Frontend framework
  gem 'rails-assets-bootstrap'
end

source 'https://rubygems.org'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Authentication
gem 'devise'

# Default environment variable config
gem 'dotenv-rails'

# Incoming emails
gem 'griddler'
gem 'griddler-sendgrid'

# HAML templates
gem 'haml-rails', '~> 0.9'

# Postgres
gem 'pg'

# Web server
gem 'puma'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.6'

# Use SCSS for stylesheets
gem 'sassc-rails'

# Runtime for execjs
gem 'therubyracer'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Loader for Javascripts
gem 'webpack-rails'

group :deployment do
  # Use Capistrano for deployment
  gem 'capistrano-npm'
  gem 'capistrano3-puma'
  gem 'capistrano-rails'
  gem 'capistrano-rvm'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Factories
  gem 'factory_girl'

  gem 'minitest-rails'

  # Run individual tests using rake matchers
  gem 'single_test'
end
