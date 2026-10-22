# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Criminality::StructureParser do
  describe '.parse' do
    def parse(year)
      described_class.parse(fixture("genpro_gov_sk/criminality/structure-#{year}.csv").read(encoding: 'Windows-1250'))
    end

    it 'parses the 2024 structure with its new metrics, for every office' do
      result = parse(2024)
      general = result.first

      expect(result.size).to eq(63)
      expect(general[:year]).to eq('2024')
      expect(general[:unknown]).to be_empty
      expect(general[:statistics].map { |statistic| statistic[:metric] }).to include(
        :prosecuted_legal_entities, :prosecuted_young_boys, :prosecuted_young_girls, :prosecuted_alcohol_abuse,
        :prosecuted_substance_abuse, :prosecuted_foreigners, :accused_recidivists_all
      )
    end

    it 'knows every metric of the 2023 and 2024 structures' do
      [2023, 2024].each do |year|
        unknown = parse(year).flat_map { |office| office[:unknown] }

        expect(unknown).to be_empty, "Unknown attributes in #{year}: #{unknown.join(', ')}"
      end
    end
  end

  describe '.normalize_metric' do
    it 'normalizes odstíhaných to stíhaných' do
      expect(described_class.normalize_metric('Skladba odstíhaných osôb')).to eq('Skladba stíhaných osôb')
    end

    it 'normalizes multiple spaces' do
      expect(described_class.normalize_metric('Skladba    stíhaných  osôb')).to eq('Skladba stíhaných osôb')
    end
  end

  describe '.calculate_sum_count' do
    it 'sums the counts of a metric\'s parts when it has none of its own' do
      statistics = [{ metric: :accused_recidivists_dangerous, count: 2 },
                    { metric: :accused_recidivists_only, count: 3 }]

      described_class.calculate_sum_count(statistics, metric: :accused_recidivists_all, count: nil)

      expect(statistics.last).to eq(metric: :accused_recidivists_all, count: 5)
    end

    it 'keeps a metric\'s own count, and sums nothing without parts' do
      statistics = [{ metric: :accused_recidivists_all, count: 7 }]

      described_class.calculate_sum_count(statistics, metric: :accused_recidivists_all, count: 7)
      described_class.calculate_sum_count([], metric: :accused_recidivists_all, count: nil)

      expect(statistics).to eq([{ metric: :accused_recidivists_all, count: 7 }])
    end
  end

  describe '.ignore_title?' do
    it 'ignores the period, the headings of the structure and the totals' do
      expect(described_class.ignore_title?('Za obdobie: od 01.01.2024 do 31.12.2024')).to be true
      expect(described_class.ignore_title?('Skladba stíhaných osôb')).to be true
      expect(described_class.ignore_title?('Počet spáchaných trestných činov')).to be true
      expect(described_class.ignore_title?('Počet spáchaných prečinov')).to be true
      expect(described_class.ignore_title?('Skladba trestných činov 1.hlava')).to be true
    end

    it 'does not ignore valid metrics' do
      expect(described_class.ignore_title?('Skladba stíhaných osôb muži')).to be_falsey
    end
  end
end
