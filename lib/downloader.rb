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
      curl.perform

      raise DownloadError, "HTTP #{curl.response_code} for #{url}" if curl.response_code >= 300

      body = curl.body_str

      block_given? ? block.call(body) : body
    rescue Curl::Err::GotNothingError, Curl::Err::TimeoutError, Curl::Err::ConnectionFailedError, DownloadError => e
      if attempt <= retries
        backoff_time = 2**attempt
        Rails.logger.info "Retry #{attempt}/#{retries} for #{url} after #{backoff_time}s: #{e.class}"
        sleep backoff_time
        retry
      else
        Rails.logger.error "Failed to download #{url} after #{retries} retries: #{e.class} - #{e.message}"
        raise
      end
    end
  end
end
