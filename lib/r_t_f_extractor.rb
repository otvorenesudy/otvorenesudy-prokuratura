require 'file_downloader'

class RTFExtractor
  def self.extract_text_from_url(url)
    FileDownloader.download(url, directory: '/tmp') do |path|
      begin
        `unoconv -f text "#{path}"`

        text = File.open("#{path}.txt", 'r').read

        [text, File.read(path)]
      ensure
        FileUtils.rm("#{path}.txt") if File.exists?("#{path}.txt")
      end
    end
  end
end
