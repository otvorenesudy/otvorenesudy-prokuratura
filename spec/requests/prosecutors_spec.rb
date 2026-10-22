# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Prosecutors' do
  describe 'the export of the estate declarations' do
    it 'lists every item, income and statement of every declaration, with the prosecutor\'s offices' do
      prosecutor = create(:prosecutor, name: 'JUDr. Ján Novák', declarations: [
                            { genpro_gov_sk_declaration_id: 1, name: 'JUDr. Ján Novák', year: 2023, url: 'https://www.genpro.gov.sk/1',
                              lists: [{ category: 'Nehnuteľnosti',
                                        items: [{ description: 'Byt', acquisition_date: '2015', acquisition_reason: 'kúpa',
                                                  price: '100 000 €', procurement_price: nil }] }],
                              incomes: [{ description: 'Plat', value: '50 000 €' }], statements: ['Žiadne'] }
                          ])
      create(:appointment, prosecutor:, office: Office.find_by!(name: 'Okresná prokuratúra Žilina'))
      create(:appointment, prosecutor:, office: Office.find_by!(name: 'Krajská prokuratúra v Žiline'), type: :temporary)

      get export_prosecutors_path

      rows = CSV.parse(response.body)

      expect(response.media_type).to eq('text/plain')
      expect(rows.first).to start_with('ID', 'Name', 'Current Office', 'Temporary Office', 'Declaration Year')
      expect(rows.drop(1)).to eq([
                                   [prosecutor.id.to_s, 'JUDr. Ján Novák', 'Okresná prokuratúra Žilina', 'Krajská prokuratúra v Žiline', '2023',
                                    'Nehnuteľnosti', 'Byt', '2015', 'kúpa', '100 000 €', nil],
                                   [prosecutor.id.to_s, 'JUDr. Ján Novák', 'Okresná prokuratúra Žilina', 'Krajská prokuratúra v Žiline', '2023',
                                    'Príjmy', 'Plat', nil, nil, nil, '50 000 €', nil],
                                   [prosecutor.id.to_s, 'JUDr. Ján Novák', 'Okresná prokuratúra Žilina', 'Krajská prokuratúra v Žiline', '2023',
                                    'Vyhlásenia', 'Žiadne', nil, nil, nil, nil, nil]
                                 ])
    end

    it 'leaves out the offices a prosecutor lacks, the incomes a declaration lacks, and those without a declaration' do
      prosecutor = create(:prosecutor, name: 'JUDr. Eva Malá', declarations: [
                            { genpro_gov_sk_declaration_id: 2, name: 'JUDr. Eva Malá', year: 2024, url: 'https://www.genpro.gov.sk/2',
                              lists: [{ category: 'Hnuteľné veci', items: [{ description: 'Auto', acquisition_date: '2020' }] }],
                              incomes: nil, statements: [] }
                          ])
      create(:prosecutor, name: 'JUDr. Peter Horváth', declarations: nil)

      get export_prosecutors_path

      expect(CSV.parse(response.body).drop(1)).to eq([
                                                       [prosecutor.id.to_s, 'JUDr. Eva Malá', nil, nil, '2024', 'Hnuteľné veci', 'Auto',
                                                        '2020', nil, nil, nil]
                                                     ])
    end
  end
end
