require 'p_d_f_extractor'
require 'legacy'

module GenproGovSk
  module Decrees
    using ::Legacy::String

    def self.import
      landing = Nokogiri.HTML(Curl.get(url()).body_str)
      last_page = landing.css('ul.govuk-pagination__list > li:last-child').text.to_i

      (1..last_page).each do |page|
        html = Curl.get(url(page: page)).body_str

        decrees = Parser.parse(html, url: base_url)

        decrees.each do |decree|
          next GenproGovSk::ImportPdfDecreeJob.perform_later(decree) if decree[:file_type] === 'pdf'
          next GenproGovSk::ImportRtfDecreeJob.perform_later(decree) if decree[:file_type] === 'rtf'

          raise ArgumentError.new("Unknown decree type: [${#{data[:type]}}]")
        end
      end
    end

    def self.url(page: 1)
      "https://www.genpro.gov.sk/informacie/uznesenie-o-zastaveni-trestneho-stihania/?datumOd=1960-01-01&page=#{page || 1}"
    end

    def self.base_url
      'https://www.genpro.gov.sk/'
    end
  end
end
