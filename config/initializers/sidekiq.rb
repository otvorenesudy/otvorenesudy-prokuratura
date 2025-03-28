Sidekiq.configure_server { |config| config.redis = { url: 'redis://localhost:6379/2' } }
Sidekiq.configure_client { |config| config.redis = { url: 'redis://localhost:6379/2' } }

if ENV['SIDEKIQ_INLINE'] == 'true'
  require 'sidekiq/testing'

  Sidekiq::Testing.inline!
end
