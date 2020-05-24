require 'spec_helper'
require 'p_d_f_extractor'

RSpec.describe PDFExtractor, type: :unit do
  describe '.extract_text_from_url' do
    let(:url) { 'https://www.genpro.gov.sk/extdoc/54888/Menny%20zoznam%20prokuratorov%20SR%20k%2015_05_2020' }

    it 'extracts text from url', vcr: { cassette_name: 'genpro_gov_sk/prosecutors-list' } do
      text, file = PDFExtractor.extract_text_from_url(url)

      expect(text.length).to eql(79_040)
      expect(text).to start_with(
        '             Priezvisko meno, titul/-y                 Pravidelné miesto výkonu funkcie'
      )
      expect(file).to eql(Curl.get(url).body_str)
    end
  end
end
