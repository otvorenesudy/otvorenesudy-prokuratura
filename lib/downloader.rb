require 'curb'

class Downloader
  class DownloadError < StandardError
  end

  def self.download(url, retries: 3, &block)
    attempt = 0

    begin
      attempt += 1

      curl = Curl::Easy.new(url)
      curl.timeout = 30
      curl.connect_timeout = 10
      curl.headers[
        'User-Agent'
      ] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
      curl.perform

      raise DownloadError, "HTTP #{curl.response_code} for #{url}" if curl.response_code >= 400

      body = curl.body_str

      block_given? ? block.call(body) : body
    rescue Curl::Err::GotNothingError, Curl::Err::TimeoutError, Curl::Err::ConnectionFailedError, DownloadError => e
      if attempt <= retries
        backoff_time = 2**attempt
        Rails.logger.info "Downloader # Retry [#{attempt}/#{retries}] for [#{url}] after [#{backoff_time}s]: [#{e.class}]"
        sleep backoff_time
        retry
      else
        Rails.logger.error "Downloader # Failed to download [#{url}] after [#{retries}] retries: [#{e.class}] - [#{e.message}]"
        raise
      end
    end
  end
end
