# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Decrees do
  describe '.import' do
    def page(number)
      described_class.url(page: number)
    end

    it 'imports each decree of every page, a PDF and an RTF one each in a job of its kind' do
      stub_source(page(1), 'genpro_gov_sk/decrees/listing.html')
      stub_source(page(2), 'genpro_gov_sk/decrees/page_1950.html')

      described_class.import

      expect(GenproGovSk::ImportPdfDecreeJob).to have_been_enqueued.exactly(21).times
      expect(GenproGovSk::ImportRtfDecreeJob).to have_been_enqueued.exactly(19).times
      expect(GenproGovSk::ImportPdfDecreeJob).to have_been_enqueued.with(
        hash_including(
          url: 'https://www.genpro.gov.sk//download/uznesenie/2025/11/za_5511_997_11_2025_a_2fc7888a717949c39beaa8e2f743f2b8.pdf',
          number: 'ZA/5511/997/11/2025', file_number: '1 Pv 53/25/5511', effective_on: Date.new(2025, 11, 19)
        )
      )
    end

    it 'refuses a decree in a format it cannot read' do
      stub_source(page(1), 'genpro_gov_sk/decrees/unknown_type.html')

      expect { described_class.import }.to raise_error(ArgumentError, 'Unknown decree type: [docx]')
    end
  end
end
