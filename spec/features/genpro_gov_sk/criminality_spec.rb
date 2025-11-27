require 'rails_helper'

RSpec.describe 'GenproGovSk::Criminality', type: :feature do
  it 'correctly imports and parses data', webmock: :disabled do
    GenproGovSk::Offices.import

    paragraphs_path = Rails.root.join('data', 'genpro_gov_sk', 'criminality', 'paragraphs', '*.xls*')
    all_paragraph_files = Dir.glob(paragraphs_path).to_a.reject { |e| e.match(/obvod/) }
    selected_paragraph_files = all_paragraph_files.sample(10, random: Random.new(42))

    GenproGovSk::Criminality.import(paragraph_paths: selected_paragraph_files)

    structure_validations = [
      { year: 2010, office: 'Okresná prokuratúra Michalovce', metric: :accused_all, count: 803 },
      { year: 2010, office: 'Okresná prokuratúra Trenčín', metric: :accused_all, count: 676 },
      { year: 2011, office: 'Okresná prokuratúra Trenčín', metric: :incoming_cases, count: 2454 },
      { year: 2011, office: 'Okresná prokuratúra Bratislava IV', metric: :reconciliation_approval, count: 7 },
      { year: 2012, office: 'Okresná prokuratúra Žilina', metric: :prosecuted_all, count: 1864 },
      { year: 2012, office: 'Krajská prokuratúra v Banskej Bystrici', metric: :incoming_cases, count: 55 },
      { year: 2013, office: 'Krajská prokuratúra v Trnave', metric: :guilt_and_sentence_agreement, count: 6 },
      { year: 2013, office: 'Okresná prokuratúra Bratislava IV', metric: :cessation_of_prosecution, count: 34 },
      { year: 2014, office: 'Okresná prokuratúra Poprad', metric: :prosecuted_all, count: 936 },
      { year: 2014, office: 'Okresná prokuratúra Dunajská Streda', metric: :accused_all, count: 889 },
      { year: 2015, office: 'Okresná prokuratúra Trenčín', metric: :accused_recidivists_all, count: 387 },
      { year: 2015, office: 'Krajská prokuratúra v Prešove', metric: :accused_all, count: 44 },
      { year: 2016, office: 'Okresná prokuratúra Spišská Nová Ves', metric: :accused_all, count: 681 },
      { year: 2016, office: 'Okresná prokuratúra Bratislava II', metric: :reconciliation_approval, count: 1 },
      { year: 2017, office: 'Okresná prokuratúra Bratislava II', metric: :guilt_and_sentence_agreement, count: 17 },
      { year: 2017, office: 'Okresná prokuratúra Michalovce', metric: :guilt_and_sentence_agreement, count: 60 },
      { year: 2018, office: 'Generálna prokuratúra Slovenskej republiky', metric: :prosecuted_all, count: 363 },
      { year: 2018, office: 'Krajská prokuratúra v Bratislave', metric: :incoming_cases, count: 57 },
      { year: 2019, office: 'Krajská prokuratúra v Trnave', metric: :accused_all, count: 64 },
      { year: 2019, office: 'Krajská prokuratúra v Košiciach', metric: :valid_court_decision_all, count: 25 },
      { year: 2020, office: 'Krajská prokuratúra v Žiline', metric: :reconciliation_approval, count: 2 },
      { year: 2020, office: 'Okresná prokuratúra Trnava', metric: :closed_cases, count: 1975 },
      { year: 2021, office: 'Okresná prokuratúra Bratislava I', metric: :guilt_and_sentence_agreement, count: 5 },
      { year: 2021, office: 'Okresná prokuratúra Bratislava I', metric: :assignation_of_prosecution, count: 11 },
      { year: 2022, office: 'Krajská prokuratúra v Banskej Bystrici', metric: :cessation_of_prosecution, count: 4 },
      { year: 2022, office: 'Krajská prokuratúra v Banskej Bystrici', metric: :incoming_cases, count: 85 },
      { year: 2023, office: 'Okresná prokuratúra Prievidza', metric: :reconciliation_approval, count: 3 },
      { year: 2023, office: 'Okresná prokuratúra Nitra', metric: :assignation_of_prosecution, count: 12 },
      { year: 2024, office: 'Okresná prokuratúra Bratislava IV', metric: :prosecuted_all, count: 284 },
      { year: 2024, office: 'Krajská prokuratúra v Prešove', metric: :incoming_cases, count: 52 }
    ]

    paragraph_validations = [
      {
        year: 2013,
        office: 'Okresná prokuratúra Žiar nad Hronom',
        metric: :prosecuted_all,
        paragraph: '§ 217 [old]',
        count: 1
      },
      {
        year: 2013,
        office: 'Okresná prokuratúra Žiar nad Hronom',
        metric: :accused_all,
        paragraph: '§ 238 [old]',
        count: 1
      },
      {
        year: 2014,
        office: 'Okresná prokuratúra Stará Ľubovňa',
        metric: :accused_all,
        paragraph: '§ 360 [new]',
        count: 3
      },
      {
        year: 2014,
        office: 'Okresná prokuratúra Stará Ľubovňa',
        metric: :accused_all,
        paragraph: '§ 231 [new]',
        count: 6
      },
      {
        year: 2014,
        office: 'Okresná prokuratúra Ružomberok',
        metric: :prosecuted_all,
        paragraph: '§ 234 [old]',
        count: 1
      },
      {
        year: 2014,
        office: 'Okresná prokuratúra Ružomberok',
        metric: :prosecuted_all,
        paragraph: '§ 247 [old]',
        count: 3
      }
    ]

    structure_validations.each do |attributes|
      office = Office.find_by(name: attributes[:office])

      expect(
        Statistic.find_by(
          year: attributes[:year],
          office_id: office.id,
          metric: attributes[:metric].to_s,
          count: attributes[:count]
        )
      ).to be_present,
      "Structure validation failed for: #{attributes.inspect}"
    end

    paragraph_validations.each do |attributes|
      office = Office.find_by(name: attributes[:office])

      expect(
        Statistic.find_by(
          year: attributes[:year],
          office_id: office.id,
          metric: attributes[:metric].to_s,
          paragraph: attributes[:paragraph],
          count: attributes[:count]
        )
      ).to be_present,
      "Paragraph validation failed for: #{attributes.inspect}"
    end
  end
end
