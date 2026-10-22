# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MinvSk::Criminality do
  describe '.import' do
    let(:links) do
      %w[https://www.minv.sk/statistiky/2002.csv https://www.minv.sk/statistiky/2020.csv]
    end

    it 'replaces the police\'s statistics by paragraph with those of the files' do
      stub_source(links[0], 'minv_sk/criminality/2002.csv')
      stub_source(links[1], 'minv_sk/criminality/2020.csv')
      create(:crime, year: 2019, metric: 'crime_discovered', paragraph: '§ 328 [new]', count: 99)

      described_class.import(links:)

      expect(Crime.find_by(year: 2020, metric: 'crime_discovered', paragraph: '§ 328 [new]').count).to eq(6)
      expect(Crime.find_by(year: 2002, metric: 'crime_solved', paragraph: '§ 118 [old]').count).to eq(26)
      expect(Crime.where(year: 2019)).to be_empty
    end
  end
end
