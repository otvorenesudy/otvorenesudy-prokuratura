require 'pdf-reader'
require 'file_downloader'

class PDFExtractor
  def self.extract_text_from_url(url)
    FileDownloader.download(url, directory: '/tmp') do |path|
      file = File.open(path, 'rb').read
      reader = PDF::Reader.new(path)

      return reader.pages.map(&:text).join(' '), file
    end
  end
end
