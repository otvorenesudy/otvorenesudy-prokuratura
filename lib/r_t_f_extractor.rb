require 'file_downloader'
require 'unoconv'

class RTFExtractor
  def self.extract_text_from_url(url)
    FileDownloader.download(url, directory: '/tmp') do |path|
      text = Unoconv.convert(path)

      [text, File.read(path)]
    end
  end
end
