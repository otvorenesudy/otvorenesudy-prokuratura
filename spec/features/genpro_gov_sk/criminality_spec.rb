require 'rails_helper'

RSpec.describe 'GenproGovSk::Criminality', type: :feature do
  it 'correctly imports and parses data', webmock: :disabled do
    GenproGovSk::Offices.import
    GenproGovSk::Criminality.import

    structure_validations = [
      # Year 2010
      { year: 2010, office: 'Krajská prokuratúra v Trnave', metric: :incoming_cases, count: 72 },
      { year: 2010, office: 'Okresná prokuratúra Bratislava V', metric: :assignation_of_prosecution, count: 30 },
      { year: 2010, office: 'Okresná prokuratúra Michalovce', metric: :closed_cases, count: 2591 },
      # Year 2011
      { year: 2011, office: 'Okresná prokuratúra Bratislava II', metric: :accused_all, count: 1164 },
      { year: 2011, office: 'Okresná prokuratúra Michalovce', metric: :closed_cases, count: 2677 },
      { year: 2011, office: 'Okresná prokuratúra Bratislava IV', metric: :incoming_cases, count: 2122 },
      # Year 2012
      { year: 2012, office: 'Okresná prokuratúra Trenčín', metric: :guilt_and_sentence_agreement, count: 297 },
      { year: 2012, office: 'Okresná prokuratúra Prievidza', metric: :closed_cases, count: 2629 },
      { year: 2012, office: 'Okresná prokuratúra Prievidza', metric: :prosecuted_all, count: 1222 },
      # Year 2013
      { year: 2013, office: 'Okresná prokuratúra Trnava', metric: :prosecuted_all, count: 551 },
      { year: 2013, office: 'Okresná prokuratúra Spišská Nová Ves', metric: :cessation_of_prosecution, count: 148 },
      { year: 2013, office: 'Okresná prokuratúra Pezinok', metric: :cessation_of_prosecution, count: 40 },
      # Year 2014
      { year: 2014, office: 'Okresná prokuratúra Čadca', metric: :prosecuted_all, count: 658 },
      { year: 2014, office: 'Okresná prokuratúra Nitra', metric: :incoming_cases, count: 3023 },
      { year: 2014, office: 'Okresná prokuratúra Michalovce', metric: :guilt_and_sentence_agreement, count: 146 },
      # Year 2015
      { year: 2015, office: 'Okresná prokuratúra Michalovce', metric: :reconciliation_approval, count: 9 },
      { year: 2015, office: 'Okresná prokuratúra Pezinok', metric: :closed_cases, count: 978 },
      { year: 2015, office: 'Okresná prokuratúra Nitra', metric: :cessation_of_prosecution, count: 80 },
      # Year 2016
      { year: 2016, office: 'Generálna prokuratúra Slovenskej republiky', metric: :incoming_cases, count: 327 },
      { year: 2016, office: 'Okresná prokuratúra Bratislava I', metric: :assignation_of_prosecution, count: 17 },
      { year: 2016, office: 'Okresná prokuratúra Spišská Nová Ves', metric: :incoming_cases, count: 1644 },
      # Year 2017
      { year: 2017, office: 'Krajská prokuratúra v Trnave', metric: :cessation_of_prosecution, count: 7 },
      { year: 2017, office: 'Okresná prokuratúra Malacky', metric: :closed_cases, count: 1055 },
      { year: 2017, office: 'Okresná prokuratúra Žilina', metric: :prosecuted_all, count: 1431 },
      # Year 2018
      { year: 2018, office: 'Okresná prokuratúra Nitra', metric: :reconciliation_approval, count: 6 },
      { year: 2018, office: 'Okresná prokuratúra Pezinok', metric: :prosecuted_all, count: 297 },
      { year: 2018, office: 'Okresná prokuratúra Poprad', metric: :incoming_cases, count: 1200 },
      # Year 2019
      { year: 2019, office: 'Okresná prokuratúra Pezinok', metric: :accused_men, count: 249 },
      { year: 2019, office: 'Krajská prokuratúra v Trnave', metric: :reconciliation_approval, count: 21 },
      { year: 2019, office: 'Okresná prokuratúra Trenčín', metric: :valid_court_decision_all, count: 774 },
      { year: 2019, office: 'Krajská prokuratúra v Bratislave', metric: :valid_court_decision_all, count: 53 },
      # Year 2020
      { year: 2020, office: 'Generálna prokuratúra Slovenskej republiky', metric: :incoming_cases, count: 456 },
      { year: 2020, office: 'Okresná prokuratúra Pezinok', metric: :closed_cases, count: 667 },
      { year: 2020, office: 'Okresná prokuratúra Nitra', metric: :prosecuted_all, count: 939 },
      # Year 2021
      { year: 2021, office: 'Okresná prokuratúra Nitra', metric: :prosecuted_all, count: 874 },
      { year: 2021, office: 'Krajská prokuratúra v Nitre', metric: :valid_court_decision_all, count: 63 },
      { year: 2021, office: 'Okresná prokuratúra Žilina', metric: :assignation_of_prosecution, count: 26 },
      # Year 2022
      { year: 2022, office: 'Okresná prokuratúra Trnava', metric: :guilt_and_sentence_agreement, count: 20 },
      { year: 2022, office: 'Okresná prokuratúra Bratislava III', metric: :assignation_of_prosecution, count: 6 },
      { year: 2022, office: 'Okresná prokuratúra Prievidza', metric: :closed_cases, count: 1052 },
      # Year 2023
      { year: 2023, office: 'Krajská prokuratúra v Žiline', metric: :guilt_and_sentence_agreement, count: 8 },
      { year: 2023, office: 'Krajská prokuratúra v Trenčíne', metric: :valid_court_decision_all, count: 39 },
      { year: 2023, office: 'Okresná prokuratúra Bratislava II', metric: :cessation_of_prosecution, count: 30 },
      # Year 2024
      { year: 2024, office: 'Okresná prokuratúra Bratislava IV', metric: :guilt_and_sentence_agreement, count: 7 },
      { year: 2024, office: 'Okresná prokuratúra Pezinok', metric: :accused_all, count: 469 },
      { year: 2024, office: 'Krajská prokuratúra v Banskej Bystrici', metric: :incoming_cases, count: 46 }
    ]

    paragraph_validations = [
      # Year 2010
      { year: 2010, office: 'Okresná prokuratúra Trenčín', metric: :exempt_all, paragraph: '§ 157 [new]', count: 2 },
      {
        year: 2010,
        office: 'Krajská prokuratúra v Košiciach',
        metric: :accused_all,
        paragraph: '§ 250 [old]',
        count: 1
      },
      {
        year: 2010,
        office: 'Okresná prokuratúra Košice I',
        metric: :convicted_all,
        paragraph: '§ 148 [old]',
        count: 1
      },
      # Year 2011
      { year: 2011, office: 'Okresná prokuratúra Košice I', metric: :judged_all, paragraph: '§ 125 [old]', count: 1 },
      {
        year: 2011,
        office: 'Krajská prokuratúra v Trenčíne',
        metric: :accused_all,
        paragraph: '§ 145 [new]',
        count: 3
      },
      { year: 2011, office: 'Okresná prokuratúra Trnava', metric: :judged_all, paragraph: '§ 148 [old]', count: 7 },
      # Year 2012
      {
        year: 2012,
        office: 'Okresná prokuratúra Bratislava II',
        metric: :exempt_all,
        paragraph: '§ 155 [new]',
        count: 1
      },
      {
        year: 2012,
        office: 'Krajská prokuratúra v Bratislave',
        metric: :judged_all,
        paragraph: '§ 145 [new]',
        count: 5
      },
      { year: 2012, office: 'Okresná prokuratúra Žilina', metric: :accused_all, paragraph: '§ 149 [new]', count: 3 },
      # Year 2013
      { year: 2013, office: 'Krajská prokuratúra v Trnave', metric: :judged_all, paragraph: '§ 145 [new]', count: 7 },
      {
        year: 2013,
        office: 'Okresná prokuratúra Bratislava I',
        metric: :exempt_all,
        paragraph: '§ 158 [new]',
        count: 1
      },
      {
        year: 2013,
        office: 'Okresná prokuratúra Bratislava V',
        metric: :prosecuted_all,
        paragraph: '§ 149 [new]',
        count: 3
      },
      # Year 2014
      {
        year: 2014,
        office: 'Krajská prokuratúra v Bratislave',
        metric: :accused_all,
        paragraph: '§ 148 [old]',
        count: 3
      },
      {
        year: 2014,
        office: 'Okresná prokuratúra Bratislava I',
        metric: :convicted_all,
        paragraph: '§ 155 [new]',
        count: 4
      },
      {
        year: 2014,
        office: 'Okresná prokuratúra Bratislava II',
        metric: :prosecuted_all,
        paragraph: '§ 148 [old]',
        count: 2
      },
      # Year 2015
      {
        year: 2015,
        office: 'Okresná prokuratúra Dunajská Streda',
        metric: :judged_all,
        paragraph: '§ 158 [old]',
        count: 1
      },
      { year: 2015, office: 'Okresná prokuratúra Žilina', metric: :convicted_all, paragraph: '§ 124 [old]', count: 1 },
      { year: 2015, office: 'Okresná prokuratúra Čadca', metric: :prosecuted_all, paragraph: '§ 149 [new]', count: 3 },
      # Year 2016
      { year: 2016, office: 'Krajská prokuratúra v Trnave', metric: :judged_all, paragraph: '§ 145 [new]', count: 1 },
      {
        year: 2016,
        office: 'Krajská prokuratúra v Trnave',
        metric: :prosecuted_all,
        paragraph: '§ 148 [old]',
        count: 6
      },
      {
        year: 2016,
        office: 'Krajská prokuratúra v Nitre',
        metric: :prosecuted_all,
        paragraph: '§ 145 [new]',
        count: 4
      },
      # Year 2017
      {
        year: 2017,
        office: 'Okresná prokuratúra Dunajská Streda',
        metric: :convicted_all,
        paragraph: '§ 149 [new]',
        count: 2
      },
      { year: 2017, office: 'Okresná prokuratúra Prešov', metric: :prosecuted_all, paragraph: '§ 147 [new]', count: 1 },
      {
        year: 2017,
        office: 'Krajská prokuratúra v Banskej Bystrici',
        metric: :convicted_all,
        paragraph: '§ 145 [new]',
        count: 4
      },
      {
        year: 2017,
        office: 'Krajská prokuratúra v Žiline',
        metric: :convicted_all,
        paragraph: '§ 158 [old]',
        count: 1
      },
      # Year 2018
      {
        year: 2018,
        office: 'Okresná prokuratúra Bratislava III',
        metric: :convicted_all,
        paragraph: '§ 147 [new]',
        count: 1
      },
      {
        year: 2018,
        office: 'Okresná prokuratúra Bratislava III',
        metric: :convicted_all,
        paragraph: '§ 148 [old]',
        count: 1
      },
      {
        year: 2018,
        office: 'Okresná prokuratúra Dunajská Streda',
        metric: :convicted_all,
        paragraph: '§ 248 [old]',
        count: 1
      },
      { year: 2018, office: 'Okresná prokuratúra Košice I', metric: :judged_all, paragraph: '§ 155 [new]', count: 7 },
      # Year 2019
      {
        year: 2019,
        office: 'Okresná prokuratúra Bratislava II',
        metric: :convicted_all,
        paragraph: '§ 149 [new]',
        count: 7
      },
      { year: 2019, office: 'Okresná prokuratúra Komárno', metric: :judged_all, paragraph: '§ 149 [new]', count: 2 },
      {
        year: 2019,
        office: 'Krajská prokuratúra v Trenčíne',
        metric: :prosecuted_all,
        paragraph: '§ 145 [new]',
        count: 5
      },
      { year: 2019, office: 'Krajská prokuratúra v Prešove', metric: :judged_all, paragraph: '§ 250 [old]', count: 1 },
      # Year 2020
      { year: 2020, office: 'Okresná prokuratúra Nitra', metric: :prosecuted_all, paragraph: '§ 213 [old]', count: 1 },
      {
        year: 2020,
        office: 'Okresná prokuratúra Bratislava III',
        metric: :prosecuted_all,
        paragraph: '§ 149 [new]',
        count: 2
      },
      { year: 2020, office: 'Okresná prokuratúra Žilina', metric: :prosecuted_all, paragraph: '§ 148 [old]', count: 1 },
      { year: 2020, office: 'Okresná prokuratúra Nitra', metric: :convicted_all, paragraph: '§ 149 [new]', count: 5 },
      # Year 2021
      {
        year: 2021,
        office: 'Krajská prokuratúra v Banskej Bystrici',
        metric: :convicted_all,
        paragraph: '§ 219 [old]',
        count: 3
      },
      { year: 2021, office: 'Okresná prokuratúra Martin', metric: :convicted_all, paragraph: '§ 149 [new]', count: 3 },
      { year: 2021, office: 'Okresná prokuratúra Trenčín', metric: :judged_all, paragraph: '§ 149 [new]', count: 7 },
      {
        year: 2021,
        office: 'Okresná prokuratúra Bratislava II',
        metric: :prosecuted_all,
        paragraph: '§ 149 [new]',
        count: 6
      },
      # Year 2022
      { year: 2022, office: 'Okresná prokuratúra Pezinok', metric: :judged_all, paragraph: '§ 149 [new]', count: 1 },
      {
        year: 2022,
        office: 'Krajská prokuratúra v Žiline',
        metric: :convicted_all,
        paragraph: '§ 145 [new]',
        count: 3
      },
      # Year 2023
      {
        year: 2023,
        office: 'Okresná prokuratúra Bratislava I',
        metric: :judged_all,
        paragraph: '§ 149 [new]',
        count: 1
      },
      {
        year: 2023,
        office: 'Okresná prokuratúra Bratislava III',
        metric: :prosecuted_all,
        paragraph: '§ 147 [new]',
        count: 2
      },
      # Year 2024
      {
        year: 2024,
        office: 'Krajská prokuratúra v Bratislave',
        metric: :prosecuted_all,
        paragraph: '§ 145 [new]',
        count: 5
      },
      {
        year: 2024,
        office: 'Okresná prokuratúra Bratislava I',
        metric: :judged_all,
        paragraph: '§ 148a [old]',
        count: 1
      },
      { year: 2024, office: 'Okresná prokuratúra Prešov', metric: :convicted_all, paragraph: '§ 149 [new]', count: 7 },
      { year: 2024, office: 'Krajská prokuratúra v Nitre', metric: :convicted_all, paragraph: '§ 158 [old]', count: 8 }
    ]

    structure_validations.each do |attributes|
      office = Office.find_by(name: attributes.delete(:office))

      expect(Statistic.find_by(attributes.merge(office_id: office.id))).to be_present,
      "Structure validation failed for: #{attributes.inspect} office=#{office&.name}"
    end

    paragraph_validations.each do |attributes|
      office = Office.find_by(name: attributes.delete(:office))

      expect(Statistic.find_by(attributes.merge(office_id: office.id))).to be_present,
      "Paragraph validation failed for: #{attributes.inspect} office=#{office&.name}"
    end
  end
end
