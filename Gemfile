source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.8.0'

gem 'rails', '~> 6.0.3', '>= 6.0.3.1'
gem 'rails-i18n', '~> 6.0.0'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 4.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'curb'
gem 'bootstrap', '~> 4.5.0'

gem 'pg', '~> 1.2.3'
gem 'bootsnap', '>= 1.4.2'

gem 'pdf-reader', '~> 2.4.0'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'webmock', '~> 3.8.3'
end

group :development, :test do
  gem 'rspec-rails', '~> 4.0.0'
  gem 'shoulda-matchers', '~> 4.3.0'
  gem 'factory_bot', '~> 5.2.0'
  gem 'vcr'
  gem 'prettier'
  gem 'pry-rails'
  gem 'rubocop', '~> 0.84', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
