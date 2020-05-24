require 'spec_helper'
require 'file_downloader'

RSpec.describe FileDownloader, type: :unit do
  describe '.download' do
    let(:url) { 'https://www.genpro.gov.sk/extdoc/54888/Menny%20zoznam%20prokuratorov%20SR%20k%2015_05_2020' }

    it 'downloads file and yields the path', vcr: { cassette_name: 'example.pdf' } do
      path = '/tmp/file-downloader-tmp-file-14bc1a3fffa5d06a08d4d2be03587e98a6bbdf53c94a55d18860d514d47872d7'

      expect { |block| FileDownloader.download(url, directory: '/tmp', &block) }.to yield_with_args(path)

      expect(File.exist?(path)).to eql(false)
    end
  end
end
