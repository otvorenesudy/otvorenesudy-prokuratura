source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

gem 'rails', '~> 6.0.3', '>= 6.0.3.1'
gem 'rails-i18n', '~> 6.0.0'
gem 'i18n-tasks', '~> 0.9.31'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 4.0'
gem 'sprockets', '~> 4.0.2'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'curb', '~> 0.9.10'
gem 'mechanize'

gem 'bootstrap', '~> 4.1.0'
gem 'svgeez', '~> 3.0'
gem 'pg', '~> 1.2.3'
gem 'pdf-reader', '~> 2.4.0'
gem 'json-schema', '~> 2.8.1'
gem 'sidekiq', '~> 5.2.9'
gem 'kaminari', '~> 1.2.1'
gem 'geocoder', '~> 1.6.3'
gem 'roo', '~> 2.8.3'
gem 'roo-xls', '~> 1.2.0'
gem 'parallel', '~> 1.19.1'
gem 'activerecord-import', '~> 1.0.6'
gem 'whenever', '~> 1.0.0'
gem 'dalli', '~> 2.7.10'
gem 'bootsnap', '>= 1.4.2'
gem 'rollbar', '~> 3.0.0'
gem 'skylight', '~> 4.3.1'
gem 'selenium-webdriver'
gem 'google-api-client', '~> 0.46.2'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2.1'
  gem 'spring', '~> 2.1.0'
  gem 'spring-watcher-listen', '~> 2.0.1'
  gem 'annotate'

  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-git'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-sidekiq', '~> 1.0.3'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'webdrivers'
  gem 'webmock', '~> 3.8.3'
  gem 'database_cleaner-active_record'
end

group :development, :test do
  gem 'rspec-rails', '~> 4.0.0'
  gem 'shoulda-matchers', '~> 4.3.0'
  gem 'factory_bot', '~> 5.2.0'
  gem 'vcr'
  gem 'prettier', '~> 3.2.2'
  gem 'prettier_print'
  gem 'syntax_tree'
  gem 'syntax_tree-haml'
  gem 'syntax_tree-rbs'
  gem 'pry-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
