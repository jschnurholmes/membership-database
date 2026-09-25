source 'https://rubygems.org'

ruby '3.3.6'

# Rails 7.2 - Latest stable version
gem 'rails', '~> 7.2.2'

# Use mysql2 as the database for Active Record
gem 'mysql2', '~> 0.5.6'

# Use haml for template language
gem 'haml', '~> 6.3'
gem 'haml-rails', '~> 2.1'

# Use jbuilder for JSON APIs
gem 'jbuilder', '~> 2.12'

# Use puma as the app server
gem 'puma', '~> 6.4'

# Asset pipeline
gem 'sprockets-rails', '~> 3.5'

# Use SCSS for stylesheets (now using sassc-rails for Rails 7)
gem 'sassc-rails', '~> 2.1'

# Use importmap for JavaScript (Rails 7 default)
gem 'importmap-rails', '~> 2.0'

# Hotwire's SPA-like page accelerator
gem 'turbo-rails', '~> 2.0'

# Hotwire's modest JavaScript framework
gem 'stimulus-rails', '~> 1.3'

# Use Terser as compressor for JavaScript assets (supports modern ES6+ syntax, unlike Uglifier)
gem 'terser'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.6'

# Search capabilities
gem 'ransack', '~> 4.2'

# Bootstrap for Rails with Sprockets (includes JS)
gem 'bootstrap', '~> 5.3'
gem 'popper_js', '~> 2.11'

# Required in newer versions of ruby
gem 'csv', '~> 3.3.5'

# Use discard for soft deletes (modern replacement for paranoia)
gem 'discard', '~> 1.3'

# Authentication
gem 'devise', '~> 4.9'

# ActionMailer delivery via SES using the ECS task's IAM role, no stored SMTP credentials
gem 'aws-sdk-rails'
gem 'aws-actionmailer-ses'

# Bootsnap for faster boot times
gem 'bootsnap', require: false

# Timezone data for Windows
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  # Debugging
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Speed up development by keeping your application running in the background
  gem 'spring'

  # Use Capistrano for deployment

  # Add a console on exceptions pages
  gem 'web-console', '~> 4.2'
end

group :test do
  # Use system testing
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.25'
end
