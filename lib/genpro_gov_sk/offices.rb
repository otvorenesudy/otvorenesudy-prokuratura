module GenproGovSk
  module Offices
    def self.import
      links =
        Nokogiri
          .HTML(Curl.get('https://www.genpro.gov.sk/kontakty-a-uradne-hodiny-12cb.html').body_str)
          .css('.content > .navigacia > li > a')
          .map { |e| "https://www.genpro.gov.sk/#{e['href']}" }

      links.map do |link|
        html = Curl.get(link).body_str
        data = Parser.parse(html)

        GenproGovSk::Office.import_from(data: data, file: html)
      end
    end
  end
end
