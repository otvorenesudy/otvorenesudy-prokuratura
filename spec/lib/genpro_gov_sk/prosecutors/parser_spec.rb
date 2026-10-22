# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Prosecutors::Parser do
  let(:rows) do
    JSON.parse(Rails.root.join('spec/fixtures/genpro_gov_sk/prosecutors/list.json').read)
  end
  let(:expected_json) do
    JSON.parse(
      Rails.root.join('spec/fixtures/genpro_gov_sk/prosecutors/all_prosecutors.json').read,
      symbolize_names: true
    )
  end

  describe '.parse' do
    it 'parses prosecutors correctly from PDF extracted rows' do
      data = described_class.parse(rows)

      expect(data.size).to eq(expected_json.size)
      expect(data).to eq(expected_json)
    end

    it 'correctly extracts name and name_parts' do
      data = described_class.parse(rows)

      expect(data).to be_an(Array).and(have_attributes(size: be > 1000))
      expect(data.first).to include(:name, :name_parts, :office, :temporary_office)
      expect(data.first[:name_parts]).to include(:first, :last, :prefix, :unprocessed)
    end

    it 'maps offices correctly using OFFICES_MAP' do
      data = described_class.parse(rows)

      data.each do |prosecutor|
        expect(described_class::OFFICES_MAP.values).to include(prosecutor[:office]) if prosecutor[:office]

        if prosecutor[:temporary_office]
          expect(described_class::OFFICES_MAP.values).to include(prosecutor[:temporary_office])
        end
      end
    end

    it 'handles prosecutors with temporary offices' do
      data = described_class.parse(rows)

      prosecutors_with_temp = data.select { |p| p[:temporary_office].present? }
      expect(prosecutors_with_temp.size).to be > 0
    end
  end
end
