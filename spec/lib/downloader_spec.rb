# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Downloader do
  describe '.download' do
    let(:url) { 'https://www.minv.sk/statistiky/test.csv' }

    it 'returns the body, or what the block makes of it' do
      stub_request(:get, url).to_return(body: 'test content')

      expect(described_class.download(url)).to eq('test content')
      expect(described_class.download(url, &:upcase)).to eq('TEST CONTENT')
    end

    it 'takes a redirect\'s body as it is' do
      stub_request(:get, url).to_return(status: 301, body: 'moved')

      expect(described_class.download(url)).to eq('moved')
    end

    it 'tries again after a server error or a dropped connection, waiting longer each time' do
      stub_request(:get, url).to_return(status: 500).then.to_raise(Curl::Err::GotNothingError).then
                             .to_return(body: 'test content')

      expect(described_class.download(url, retries: 3)).to eq('test content')
      expect(a_request(:get, url)).to have_been_made.times(3)
    end

    it 'gives up once the retries run out' do
      stub_request(:get, url).to_return(status: 404)

      expect do
        described_class.download(url, retries: 1)
      end.to raise_error(Downloader::DownloadError, "HTTP 404 for #{url}")
      expect(a_request(:get, url)).to have_been_made.times(2)
    end
  end
end
