require 'rails_helper'

RSpec.describe Downloader do
  describe '.download' do
    let(:url) { 'https://example.com/test.csv' }
    let(:body) { 'test content' }

    context 'with successful download' do
      it 'returns body when no block given' do
        curl = instance_double(Curl::Easy)
        allow(Curl::Easy).to receive(:new).with(url).and_return(curl)
        allow(curl).to receive(:timeout=)
        allow(curl).to receive(:connect_timeout=)
        allow(curl).to receive(:perform)
        allow(curl).to receive(:response_code).and_return(200)
        allow(curl).to receive(:body_str).and_return(body)

        result = described_class.download(url)

        expect(result).to eq(body)
      end

      it 'yields body to block when block given' do
        curl = instance_double(Curl::Easy)
        allow(Curl::Easy).to receive(:new).with(url).and_return(curl)
        allow(curl).to receive(:timeout=)
        allow(curl).to receive(:connect_timeout=)
        allow(curl).to receive(:perform)
        allow(curl).to receive(:response_code).and_return(200)
        allow(curl).to receive(:body_str).and_return(body)

        result = described_class.download(url) { |b| b.upcase }

        expect(result).to eq('TEST CONTENT')
      end
    end

    context 'with HTTP error' do
      it 'does not raise on 3xx redirect codes' do
        curl = instance_double(Curl::Easy)
        allow(Curl::Easy).to receive(:new).with(url).and_return(curl)
        allow(curl).to receive(:timeout=)
        allow(curl).to receive(:connect_timeout=)
        allow(curl).to receive(:perform)
        allow(curl).to receive(:response_code).and_return(301)
        allow(curl).to receive(:body_str).and_return(body)

        result = described_class.download(url)

        expect(result).to eq(body)
      end

      it 'retries on 4xx and 5xx response codes' do
        curl = instance_double(Curl::Easy)
        allow(Curl::Easy).to receive(:new).with(url).and_return(curl)
        allow(curl).to receive(:timeout=)
        allow(curl).to receive(:connect_timeout=)
        allow(curl).to receive(:perform)
        allow(curl).to receive(:response_code).and_return(500, 200)
        allow(curl).to receive(:body_str).and_return(body)
        allow(Rails.logger).to receive(:info)

        result = described_class.download(url, retries: 3)

        expect(result).to eq(body)
      end

      it 'raises after max retries' do
        curl = instance_double(Curl::Easy)
        allow(Curl::Easy).to receive(:new).with(url).and_return(curl)
        allow(curl).to receive(:timeout=)
        allow(curl).to receive(:connect_timeout=)
        allow(curl).to receive(:perform)
        allow(curl).to receive(:response_code).and_return(500)
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:error)

        expect { described_class.download(url, retries: 3) }.to raise_error(Downloader::DownloadError)
      end
    end

    context 'with network error' do
      it 'retries on Curl errors' do
        curl = instance_double(Curl::Easy)
        allow(Curl::Easy).to receive(:new).with(url).and_return(curl)
        allow(curl).to receive(:timeout=)
        allow(curl).to receive(:connect_timeout=)
        allow(curl).to receive(:perform).and_raise(Curl::Err::GotNothingError).once.and_return(nil)
        allow(curl).to receive(:response_code).and_return(200)
        allow(curl).to receive(:body_str).and_return(body)
        allow(Rails.logger).to receive(:info)

        result = described_class.download(url, retries: 3)

        expect(result).to eq(body)
      end
    end
  end
end
