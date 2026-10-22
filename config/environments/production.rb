# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # nginx serves /assets itself; this covers anything it passes through.
  config.public_file_server.headers = { 'cache-control' => "public, max-age=#{1.year.to_i}" }

  # nginx terminates TLS and redirects plain HTTP.
  config.assume_ssl = true
  config.force_ssl = true

  # Links built from the request (the canonical URL, og:image) name the host it sends, X-Forwarded-Host included;
  # other hosts get 403.
  config.hosts = %w[prokuratura.otvorenesudy.sk]

  # Passenger sends STDOUT to its own log; the app logs to shared/log, which logrotate rotates.
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger(Rails.root.join('log/production.log').to_s)
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Memcached is shared with otvorenesudy and otvorenesudy-api on the server.
  config.cache_store = :mem_cache_store, 'localhost:11211', { namespace: 'otvorenesudy-prokuratura', compress: true }

  config.active_job.queue_name_prefix = 'otvorenesudy_prokuratura_production'

  config.i18n.fallbacks = true

  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]

  Rails.application.routes.default_url_options = { host: 'prokuratura.otvorenesudy.sk', protocol: 'https' }
end
