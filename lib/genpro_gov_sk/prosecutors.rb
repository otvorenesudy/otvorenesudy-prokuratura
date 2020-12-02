require 'p_d_f_extractor'

module GenproGovSk
  module Prosecutors
    def self.import(force: false)
      html =
        Curl.get('https://www.genpro.gov.sk/prokuratura-sr/menny-zoznam-prokuratorov-slovenskej-republiky-3928.html')
          .body_str

      path = Nokogiri.HTML(html).css('a').find { |e| e.text =~ /Menný zoznam prokurátorov SR/ }[:href]
      url = "https://www.genpro.gov.sk#{path}"

      text, file = PDFExtractor.extract_text_from_url(url)

      data = Parser.parse(text)

      GenproGovSk::ProsecutorsList.import_from(data: data, file: file, force: force)
    end
  end
end
