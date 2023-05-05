require 'p_d_f_extractor'
require 'legacy'

module GenproGovSk
  module Prosecutors
    using ::Legacy::String

    def self.import(force: false)
      html =
        Curl.get('https://www.genpro.gov.sk/prokuratura-sr/menny-zoznam-prokuratorov-slovenskej-republiky-3928.html')
          .body_str

      path = Nokogiri.HTML(html).css('a').find { |e| e.text.ascii =~ /Menny zoznam prokuratorov SR/ }[:href]
      url = "https://www.genpro.gov.sk#{path}"

      text, file = PDFExtractor.extract_text_from_url(url)

      data = Parser.parse(text)

      GenproGovSk::ProsecutorsList.import_from(data: data, file: file, force: force)
    end

    def self.import_decrees
      url = 'https://www.genpro.gov.sk/dokumenty/pravoplatne-uznesenia-prokuratora-ktorymi-sa-skoncilo-trestne-stihanie-vedene-proti-urcitej-2f09.html'
      html = Curl.get(url).body_str
      links = Nokogiri.HTML(html).css('a[href^="?date_to"]').map { |e| e[:href] }

      links.each do |link|
        list_url = "#{url}#{link}"
        html = Curl.get(list_url).body_str

        decrees = DecreesParser.parse(html, url: url)

        decrees.each do |decree|
          GenproGovSk::ImportDecreeJob.perform_later(decree)
        end
      end
    end
  end
end
