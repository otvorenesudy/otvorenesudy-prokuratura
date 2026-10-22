# frozen_string_literal: true

# Redis database 2 on the server is this app's; otvorenesudy and otvorenesudy-api use others.
redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/2') }

Sidekiq.configure_server { |config| config.redis = redis }
Sidekiq.configure_client { |config| config.redis = redis }

# SIDEKIQ_INLINE=true runs jobs as they're enqueued, without Redis or a worker (an import in development).
Sidekiq.testing!(:inline) if ENV['SIDEKIQ_INLINE'] == 'true'
