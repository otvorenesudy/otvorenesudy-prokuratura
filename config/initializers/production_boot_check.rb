# frozen_string_literal: true

# Production's secrets come from the encrypted production credentials (config/credentials/production.yml.enc and its
# key), the database login from the environment (the deploy user's ~/.env). Production doesn't boot without them, and
# says which are missing:
#
#   secret_key_base              signs sessions and cookies
#   sidekiq.username, .password  the Sidekiq dashboard's login
#   google.analytics.tracking_id Google Analytics, once the visitor allows analytics cookies
#   google.api.search.key, .id   Google Custom Search, for the news about offices and prosecutors
#   geoapify.key                 geocodes the offices' addresses on import
#   sentry.dsn                   error reports
#   skylight.token               performance monitoring
PRODUCTION_SECRETS = [
  [:secret_key_base],
  %i[sidekiq username],
  %i[sidekiq password],
  %i[google analytics tracking_id],
  %i[google api search key],
  %i[google api search id],
  %i[geoapify key],
  %i[sentry dsn],
  %i[skylight token]
].freeze

# SECRET_KEY_BASE_DUMMY is Rails' signal that no real secrets are there (building assets): nothing to check then.
if Rails.env.production? && !ENV['SECRET_KEY_BASE_DUMMY']
  missing = PRODUCTION_SECRETS.reject { |path| Rails.application.credentials.dig(*path).present? }

  if missing.any?
    raise "Missing production credentials: #{missing.map { |path| path.join('.') }.join(', ')}. " \
          'Add them with bin/rails credentials:edit --environment production.'
  end
end
