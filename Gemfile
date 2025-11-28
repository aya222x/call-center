source "https://rubygems.org"

ruby "3.3.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.1"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Vite for asset bundling and Hot Module Replacement in Rails
gem "vite_rails", "~> 3.0"
# Inertia.js adapter for Rails [https://github.com/inertiajs/inertia-rails]
gem "inertia_rails", "~> 3.10"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.20"

# JWT for token-based authentication
gem "jwt", "~> 2.7"

# CORS for cross-origin requests
gem "rack-cors", "~> 2.0"

# Helps moving logic to service objects
gem "active_interaction", "~> 5.5"

# For managing authorization through policies
gem "pundit", "~> 2.4"

# Pagination
gem "pagy", "~> 9.3"

# Search
gem "ransack"

# Audit trail for ActiveRecord models
gem "audited", "~> 5.6"

# OpenAI API client for transcription and evaluation
gem "ruby-openai", "~> 7.3"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Active Storage validations
gem "active_storage_validations", "~> 1.2"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Writing and running tests
  gem "rspec-rails", "~> 7.1"
  # Replaces standard Rails fixtures
  gem "factory_bot_rails", "~> 6.4"
  # Generates realistic test data
  gem "faker", "~> 3.5"
  # Annotates Rails/ActiveRecord Models based on the database schema
  gem "annotaterb", "~> 4.14"

  # Load environment variables from .env file
  gem "dotenv-rails", "~> 3.1"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # Opens emails in a web interface (iframe compatible)
  gem "letter_opener_web", "~> 3.0"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  # One-liners to test common Rails functionality
  gem "shoulda-matchers", "~> 6.4"
  # For testing controller layouts and templates
  gem "rails-controller-testing"
  # Cleans test database between runs
  gem "database_cleaner-active_record", "~> 2.2"
end

gem "dockerfile-rails", ">= 1.7", group: :development

gem "litestream", "~> 0.14.0"

gem "aws-sdk-s3", "~> 1.201", require: false
