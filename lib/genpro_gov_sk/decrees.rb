require 'p_d_f_extractor'
require 'legacy'

module GenproGovSk
  module Decrees
    using ::Legacy::String

    def self.import
      url =
        'https://www.genpro.gov.sk/dokumenty/pravoplatne-uznesenia-prokuratora-ktorymi-sa-skoncilo-trestne-stihanie-vedene-proti-urcitej-2f09.html'
      html = Curl.get(url).body_str
      links = Nokogiri.HTML(html).css('a[href^="?date_to"]').map { |e| e[:href] }

      links.each do |link|
        list_url = "#{url}#{link}"
        html = Curl.get(list_url).body_str

        decrees = Parser.parse(html, url: url)

        decrees.each do |decree|
          next GenproGovSk::ImportPdfDecreeJob.perform_later(decree) if decree[:file_type] === 'pdf'
          next GenproGovSk::ImportRtfDecreeJob.perform_later(decree) if decree[:file_type] === 'rtf'

          raise ArgumentError.new("Unknown decree type: [${#{data[:type]}}]")
        end
      end
    end
  end
end