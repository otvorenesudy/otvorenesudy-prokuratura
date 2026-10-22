# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenproGovSk::Criminality::ParagraphsParser do
  # A spreadsheet of each report, code and year in data/, by the start of its name: year, report, office and code.
  let(:prefixes) do
    %w[
      2010_12_Z1003_6610_TZ_od_2006
      2010_12_Z1002_2206_TZ_do_2005
      2010_12_Z1002_6611_TZ_od_2006
      2011_12_Z1002_2202_TZ_od_2006
      2011_12_Z1003_4400_TZ_od_2006
      2011_12_Z1002_7703_TZ_do_2005
      2012_12_Z1003_2200_TZ_do_2005
      2012_12_Z1003_7703_TZ_od_2006
      2012_12_Z1003_7707_TZ_od_2006
      2013_12_Z1003_6613_TZ_do_2005
      2013_12_Z1003_4406_TZ_do_2005
      2013_12_Z1003_5506_TZ_do_2005
      2014_12_Z1003_3309_TZ_do_2005
      2014_12_Z1002_8808_TZ_do_2005
      2014_12_Z1002_8807_TZ_do_2005
      2015_12_Z1003_6609_TZ_do_2005
      2015_12_Z1003_7712_TZ_od_2006
      2015_12_Z1003_8802_TZ_do_2005
      2016_12_Z1002_8810_TZ_do_2005
      2016_12_Z1003_1107_TZ_do_2005
      2016_12_Z1003_2207_TZ_od_2006
      2017_12_Z1002_6601_TZ_do_2005
      2017_12_Z1003_6611_TZ_do_2005
      2017_12_Z1002_5511_TZ_do_2005
      2018_12_Z1003_6603_TZ_do_2005
      2018_12_Z1002_2201_TZ_do_2005
      2018_12_Z1002_6601_TZ_do_2005
      2019_12_Z1002_3301_TZ_od_2006
      2019_12_Z1002_5507_TZ_do_2005
      2019_12_Z1002_8802_TZ_do_2005
      2020_12_Z1002_2204_TZ_do_2005
      2020_12_Z1003_3304_TZ_do_2005
      2020_12_Z1002_3304_TZ_do_2005
      2021_12_Z1002_3309_TZ_od_2006
      2021_12_Z1003_2204_TZ_od_2006
      2021_12_Z1003_3307_TZ_do_2005
      2022_12_Z1002_8811_TZ_od_2006
      2022_12_Z1003_3307_TZ_od_2006
      2022_12_Z1003_2200_TZ_od_2006
      2023_12_Z1002_2207_TZ_od_2006
      2023_12_Z1002_5507_TZ_od_2006
      2023_12_Z1003_8806_TZ_od_2006
      2024_12_Z1003_6610_TZ_od_2006
      2024_12_Z1002_8808_TZ_od_2006
      2024_12_Z1003_3301_TZ_od_2006
    ]
  end

  # The office's own spreadsheet, not its district's ("obvod"), which the importer leaves out.
  def path(prefix)
    paths = Rails.root.glob("data/genpro_gov_sk/criminality/paragraphs/#{prefix}_*.xls*").reject do |path|
      path.basename.to_s.include?('obvod')
    end

    raise "No one spreadsheet starts with #{prefix}: #{paths}" unless paths.one?

    paths.first.to_s
  end

  describe '.parse' do
    it 'reads the year, the office, the code and the statistics of each kind of spreadsheet' do
      results = prefixes.filter_map { |prefix| described_class.parse(path(prefix)) }

      expect(results).to all(
        include(
          year: be_present,
          office: be_present,
          type: be_in(%i[old new]),
          statistics: an_instance_of(Array),
          unknown: an_instance_of(Array)
        )
      )
      expect(results.flat_map { |result| result[:statistics] }).to all(include(:metric, :paragraph, :count))
    end

    it 'knows all but a few titles of the spreadsheets of 2023 and 2024' do
      results = prefixes.grep(/\A202[34]/).filter_map { |prefix| described_class.parse(path(prefix)) }

      expect(results.map { |result| result[:unknown].uniq.size }).to all(be <= 5)
    end

    context 'with the rows of a report' do
      let(:heading) do
        [
          ['Prehľad o stíhaných a obžalovaných osobách - Prehľad za OP Žilina'],
          ['Za obdobie 2024'],
          ['podľa paragrafov trestného zákona od roku 2006'],
          [nil, '§ 212', '§ 328']
        ]
      end

      it 'reads the counts by paragraph, sums the recidivists and lists the titles it doesn\'t know' do
        rows = [
          *heading,
          ['Obžalovaných osôb - recidivisti', '3', '1'],
          ['Obžalovaných osôb - obzvlášť nebezpeční recidivisti', '1', ''],
          [nil, '5', '5'],
          ['Neznámy riadok', '1', '1']
        ]

        result = described_class.new(rows).parse

        expect(result)
          .to include(year: 2024, office: 'Okresná prokuratúra Žilina', type: :new, unknown: ['Neznámy riadok'])
        expect(result[:statistics]).to include(
          { metric: :accused_recidivists_all, paragraph: '§ 212 [new]', count: 4 },
          { metric: :accused_recidivists_all, paragraph: '§ 328 [new]', count: 1 }
        )
      end

      it 'reads nothing from rows of a report it doesn\'t know' do
        rows = [['Iný prehľad'], [nil, '§ 212'], ['Obžalovaných osôb - recidivisti', '3']]

        expect(described_class.new(rows).parse).to be_nil
      end
    end

    context 'with the spreadsheets of 2024, of a new form' do
      it 'reads the new metrics of the accused' do
        result = described_class.parse(path('2024_12_Z1002_8808_TZ_od_2006'))

        expect(result).to include(year: 2024, statistics: be_present)
        expect(result[:statistics].pluck(:metric))
          .to include(:prosecuted_legal_entities).or(include(:prosecuted_natural_persons))
          .or(include(:prosecuted_adults_all))
      end

      it 'reads the new metrics of the convicted' do
        result = described_class.parse(path('2024_12_Z1003_6610_TZ_od_2006'))

        expect(result).to include(year: 2024, statistics: be_present)
        expect(result[:statistics].pluck(:metric))
          .to include(:convicted_legal_entities).or(include(:convicted_natural_persons))
          .or(include(:convicted_foreigners))
      end
    end
  end
end
