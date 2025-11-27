require 'rails_helper'

RSpec.describe GenproGovSk::Declarations, webmock: :disabled do
  describe '.import' do
    it 'fetches all pages and calls ImportDeclarationsJob for each page' do
      landing_html = Curl.get('https://www.genpro.gov.sk/majetkove-priznania/').body_str
      doc = Nokogiri.HTML(landing_html)
      expected_last_page = doc.css('ul.govuk-pagination__list > li:last-child').text.to_i

      expect(expected_last_page).to be > 1

      allow(GenproGovSk::ImportDeclarationsJob).to receive(:perform_later)

      described_class.import

      expect(GenproGovSk::ImportDeclarationsJob).to have_received(:perform_later).exactly(expected_last_page).times

      expected_urls =
        (1..expected_last_page).map { |page| "https://www.genpro.gov.sk/majetkove-priznania/?page=#{page}" }

      expected_urls.each { |url| expect(GenproGovSk::ImportDeclarationsJob).to have_received(:perform_later).with(url) }
    end

    it 'extracts the correct number of pages from the pagination' do
      landing_html = Curl.get('https://www.genpro.gov.sk/majetkove-priznania/').body_str
      doc = Nokogiri.HTML(landing_html)

      expected_last_page = doc.css('ul.govuk-pagination__list > li:last-child').text.to_i

      expect(expected_last_page).to be >= 600
    end
  end
end
