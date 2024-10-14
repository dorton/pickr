source "https://rubygems.org"

ruby "3.2.2"

gem "bootsnap", require: false

gem "rubocop"

gem "devise" 

gem "httparty"

gem 'vite_rails'

gem 'sidekiq'

gem 'whenever', require: false

gem 'administrate', '~> 0.20.1'

gem 'sorbet'

gem "inertia_rails", "~> 3.0"
# Brings Rails named routes to modern javascript (https://github.com/elmassimo/js_from_routes)
gem "js_from_routes", "~> 2.0.4", group: :development

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.1"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  gem "pry"
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

end

