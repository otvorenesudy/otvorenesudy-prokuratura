# frozen_string_literal: true

require 'curb'

class Downloader
  class DownloadError < StandardError
  end

  RETRIED = [
    Curl::Err::GotNothingError, Curl::Err::TimeoutError, Curl::Err::ConnectionFailedError, DownloadError
  ].freeze

  def self.download(url, retries: 3)
    attempt = 0

    begin
      attempt += 1
      body = fetch(url)

      block_given? ? yield(body) : body
    rescue *RETRIED => e
      if attempt > retries
        Rails.logger.error "Downloader # Failed to download [#{url}] after [#{retries}] retries: " \
                           "[#{e.class}] - [#{e.message}]"
        raise
      end

      backoff_time = 2**attempt
      Rails.logger.info "Downloader # Retry [#{attempt}/#{retries}] for [#{url}] after [#{backoff_time}s]: [#{e.class}]"
      sleep backoff_time
      retry
    end
  end

  def self.fetch(url)
    curl = Curl::Easy.new(url)
    curl.timeout = 30
    curl.connect_timeout = 10
    curl.perform

    raise DownloadError, "HTTP #{curl.response_code} for #{url}" if curl.response_code >= 400

    curl.body_str
  end
  private_class_method :fetch
end
