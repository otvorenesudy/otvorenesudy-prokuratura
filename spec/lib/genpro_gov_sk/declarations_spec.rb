# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Declarations do
  describe '.import' do
    it 'imports every page of the estate declarations, each in a job of its own' do
      stub_source('https://www.genpro.gov.sk/majetkove-priznania/', 'genpro_gov_sk/declaration_listings/listing.html')

      described_class.import

      expect(GenproGovSk::ImportDeclarationsJob).to have_been_enqueued.exactly(738).times
      expect(GenproGovSk::ImportDeclarationsJob)
        .to have_been_enqueued.with('https://www.genpro.gov.sk/majetkove-priznania/?page=1')
      expect(GenproGovSk::ImportDeclarationsJob)
        .to have_been_enqueued.with('https://www.genpro.gov.sk/majetkove-priznania/?page=738')
    end
  end
end
