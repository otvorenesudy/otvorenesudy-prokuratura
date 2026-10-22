# frozen_string_literal: true

require_relative 'boot'
require_relative 'version'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'

Bundler.require(*Rails.groups)

module OpenCourts
  module Prokuratura
    class Application < Rails::Application
      config.load_defaults 8.1

      config.time_zone = 'Europe/Bratislava'

      config.i18n.available_locales = %i[en sk]
      config.i18n.default_locale = Rails.env.test? ? :en : :sk
      config.i18n.fallbacks = true

      # nginx sets X-XSS-Protection itself.
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-Content-Type-Options' => 'nosniff'
      }

      # Error pages are rendered by ErrorsController, in the site's layout and the visitor's language.
      config.exceptions_app = routes

      # db/structure.sql: the search's materialized views (offices_search, prosecutors_search, paragraphs_search) are
      # beyond what schema.rb can express.
      config.active_record.schema_format = :sql

      config.active_job.queue_adapter = :sidekiq

      # The bootstrap gem is here for its SCSS. Its JavaScript, and popper_js's, are global bundles named like the
      # modules in vendor/javascript (bootstrap.js), and Propshaft serves the first file of a name: with the gems inside
      # the app (vendor/bundle, as in CI), that was the gem's.
      config.assets.excluded_paths += %w[bootstrap popper_js].map do |name|
        Pathname(Gem.loaded_specs.fetch(name).full_gem_path).join('assets/javascripts')
      end

      config.generators do |generate|
        generate.test_framework :rspec
        generate.system_tests nil
      end

      config.skylight.probes << 'active_job'
    end
  end
end

require 'legacy'
require 'genpro_gov_sk'
require 'minv_sk'
require 'exception_handler'
