require 'p_d_f_extractor'
require 'legacy'

module GenproGovSk
  module Prosecutors
    using ::Legacy::String

    def self.import(force: false)
      html = Curl.get('https://www.genpro.gov.sk/menny-zoznam-prokuratorov-slovenskej-republiky').body_str

      path = Nokogiri.HTML(html).css('a').find { |e| e.text.ascii =~ /Menny zoznam prokuratorov SR/ }[:href]
      url = "https://www.genpro.gov.sk#{path}"

      rows, file =
        FileDownloader.download(url, extension: 'pdf') { |path| [PDFParser.parse(path), File.open(path, 'rb').read] }
      data = Parser.parse(rows)

      GenproGovSk::ProsecutorsList.import_from(data: data, file: file, force: force)
    end
  end
end
