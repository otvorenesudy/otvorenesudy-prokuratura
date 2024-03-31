require 'i18n'

module GenproGovSk
  module Declarations
    def self.import
      GenproGovSk::Declaration.delete_all

      landing = Nokogiri.HTML(Curl.get('https://www.genpro.gov.sk/majetkove-priznania/').body_str)
      last_page = landing.css('ul.govuk-pagination__list > li:last-child').text.to_i

      (1..last_page).each do |page|
        url = "https://www.genpro.gov.sk/majetkove-priznania/?page=#{page}"

        GenproGovSk::ImportDeclarationsJob.perform_later(url)
      end
    end
  end
end
