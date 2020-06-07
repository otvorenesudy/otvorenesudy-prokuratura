require_relative 'boot'
require_relative 'version'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OpenCourts
  module Prokuratura
    class Application < Rails::Application
      config.load_defaults 6.0

      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration can go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded after loading
      # the framework and any gems in your application.

      # Time Zone
      config.time_zone = 'Europe/Bratislava'

      # Databa Schema Format
      config.active_record.schema_format = :ruby

      # I18n
      config.i18n.available_locales = %i[en sk]
      config.i18n.default_locale = :sk
      config.i18n.fallbacks = [I18n.default_locale]
    end
  end
end

require 'legacy'
require 'genpro_gov_sk'
