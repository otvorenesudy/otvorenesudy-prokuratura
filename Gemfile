source 'https://rubygems.org'

ruby file: '.ruby-version'

gem 'rails', '~> 8.1.4'

# database
gem 'pg', '~> 1.7'

# server
gem 'bootsnap', require: false
gem 'puma', '>= 7.0'
gem 'rack-attack'

# assets
gem 'bootstrap', '~> 5.3'
gem 'dartsass-rails'
gem 'importmap-rails'
gem 'propshaft'
gem 'stimulus-rails'
gem 'turbo-rails'

# views
gem 'kaminari', '~> 1.2'
gem 'rails-i18n', '~> 8.1'

# jobs
gem 'sidekiq', '~> 8.1'

# caching
gem 'dalli'

# monitoring
gem 'sentry-rails', '~> 7.1'
gem 'sentry-ruby', '~> 7.1'
gem 'sentry-sidekiq', '~> 7.1'
gem 'skylight', '~> 7.1'

# scheduling
gem 'whenever', '~> 1.1', require: false

# sitemap
gem 'sitemap_generator', '~> 7.1'

# importers: genpro.gov.sk and minv.sk pages, PDF, RTF and spreadsheet documents
gem 'csv'
gem 'curb'
gem 'iguvium'
gem 'parallel'
gem 'pdf-reader'
gem 'roo'
gem 'roo-xls'

# validation of the JSON columns
gem 'json-schema'

# addresses of the offices
gem 'geocoder'

# news about offices and prosecutors (Google Custom Search)
gem 'google-apis-customsearch_v1'

# bots kept off the search pages
gem 'crawler_detect'

# the charts' PNG export, rendered by headless Chrome
gem 'selenium-webdriver', '~> 4.51'

group :development, :test do
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'debug', require: 'debug/prelude'
  gem 'dotenv-rails', '~> 3.2'
  gem 'factory_bot_rails', '~> 6.5'
  gem 'i18n-tasks', require: false
  gem 'rspec-rails', '~> 8.0'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'shoulda-matchers'
  gem 'vcr'
end

group :development do
  gem 'annotaterb', require: false
  gem 'bcrypt_pbkdf', require: false
  gem 'bump', git: 'https://github.com/pavolzbell/bump.git', require: false
  gem 'capistrano', '~> 3.20', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rbenv', require: false
  gem 'capistrano-sidekiq', require: false
  gem 'ed25519', require: false
  gem 'svgeez', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara', '~> 3.40'
  # undercover 0.8 reads SimpleCov 0.x results; move to SimpleCov 1.x with undercover's next release.
  gem 'simplecov', '~> 0.22', require: false
  gem 'undercover', '~> 0.8.5', require: false
  gem 'webmock', '~> 3.32'
end
