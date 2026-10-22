# frozen_string_literal: true

module ExceptionHandler
  def self.run
    yield
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
